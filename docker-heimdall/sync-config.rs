#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1.0"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.8"
//! clap = { version = "4.5", features = ["derive"] }
//! owo-colors = { version = "4.1", features = ["supports-colors"] }
//! ```

use anyhow::{Context, Result};
use clap::builder::styling::{AnsiColor, Effects, Styles};
use clap::Parser;
use owo_colors::OwoColorize;
use serde::Deserialize;
use std::env;
use std::path::Path;
use std::process::Command;

const HELP_STYLES: Styles = Styles::styled()
    .header(AnsiColor::Blue.on_default().effects(Effects::BOLD))
    .usage(AnsiColor::Blue.on_default().effects(Effects::BOLD))
    .literal(AnsiColor::Cyan.on_default().effects(Effects::BOLD))
    .placeholder(AnsiColor::Cyan.on_default())
    .error(AnsiColor::Red.on_default().effects(Effects::BOLD))
    .valid(AnsiColor::Green.on_default())
    .invalid(AnsiColor::Yellow.on_default());

const GENESIS_URL: &str =
    "https://storage.googleapis.com/mainnet-heimdallv2-genesis/migrated_dump-genesis.json";

#[derive(Debug, Deserialize)]
struct BuildConfig {
    package: PackageConfig,
}

#[derive(Debug, Deserialize)]
struct PackageConfig {
    #[allow(dead_code)]
    name: String,
    version: String,
}

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Download and prepare config files for heimdall", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let current_dir = env::current_dir().context("Failed to get current directory")?;
    let config_dir = current_dir.join("config");

    let config = read_build_config(&current_dir)?;
    let version = &config.package.version;
    let docker_image = format!("0xpolygon/heimdall-v2:{version}");

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {} {}",
        "Syncing config for".bold().cyan(),
        "heimdall".bold().green(),
        format!("v{version}").dimmed()
    );
    println!("{}", "━".repeat(60).bright_black());

    let home_dir = env::var("HOME").context("HOME environment variable not set")?;
    let heimdall_home = format!("{home_dir}/heimdall");

    // Step 1: Clean up previous heimdall home
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Cleaning up previous heimdall home...".bold()
    );
    if args.dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("rm -rf {heimdall_home}").dimmed()
        );
    } else {
        if std::path::Path::new(&heimdall_home).exists() {
            std::fs::remove_dir_all(&heimdall_home)
                .with_context(|| format!("Failed to remove {heimdall_home}"))?;
        }
        println!("  {} Cleaned up", "✓".bold().green());
    }

    // Step 2: Generate basic configurations via docker
    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Generating basic configurations via".bold(),
        docker_image.yellow()
    );
    run_command_exit_on_error(
        &[
            "docker", "run",
            "-v", &format!("{heimdall_home}:/heimdall-home:rw"),
            "--entrypoint", "/usr/bin/heimdalld",
            "-it", &docker_image,
            "init", "chainargos",
            "--home=/heimdall-home",
            "--chain-id", "heimdallv2-137",
        ],
        &current_dir,
        args.dry_run,
    )?;

    // Step 3: Create config directory and copy generated configs
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Copying generated config files...".bold()
    );
    if args.dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("mkdir -p {}", config_dir.display()).dimmed()
        );
    } else {
        std::fs::create_dir_all(&config_dir)
            .with_context(|| format!("Failed to create directory: {}", config_dir.display()))?;
    }

    for file in &["app.toml", "client.toml", "config.toml"] {
        let src = format!("{heimdall_home}/config/{file}");
        let dest = config_dir.join(file);
        if args.dry_run {
            println!(
                "  {} {} → {}",
                "[DRY RUN]".bold().yellow(),
                src.dimmed(),
                dest.display().to_string().dimmed()
            );
        } else {
            std::fs::copy(&src, &dest)
                .with_context(|| format!("Failed to copy {src} → {}", dest.display()))?;
            println!(
                "  {} {} → {}",
                "✓".bold().green(),
                file.bright_white(),
                dest.display().to_string().dimmed()
            );
        }
    }

    // Step 4: Download genesis file
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Downloading genesis file...".bold()
    );
    let genesis_path = config_dir.join("genesis.json");
    download_file(GENESIS_URL, &genesis_path, args.dry_run)?;

    // Step 5: Compress genesis file
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Compressing genesis file...".bold()
    );
    run_command_exit_on_error(
        &["xz", "-9", &genesis_path.to_string_lossy()],
        &current_dir,
        args.dry_run,
    )?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}

fn read_build_config(dir: &Path) -> Result<BuildConfig> {
    let config_path = dir.join("build.toml");
    let config_content = std::fs::read_to_string(&config_path)
        .with_context(|| format!("Failed to read config file: {}", config_path.display()))?;
    toml::from_str(&config_content).context("Failed to parse build.toml")
}

fn download_file(url: &str, path: &Path, dry_run: bool) -> Result<()> {
    let path_str = path.to_string_lossy();
    let command = ["curl", "-L", "-f", "-s", "-S", url, "-o", &path_str];

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            command.join(" ").dimmed()
        );
    } else {
        let command_string = command.join(" ");
        println!("  {} {}", "⠿".cyan(), command_string.dimmed());

        let status = Command::new(command[0])
            .args(&command[1..])
            .status()
            .with_context(|| format!("Failed to execute command: {command_string}"))?;

        if !status.success() {
            eprintln!(
                "  {} Download failed for {}",
                "✗".bold().red(),
                url.dimmed()
            );
            anyhow::bail!("Download failed for {url}");
        }

        println!("  {} Downloaded {}", "✓".bold().green(), path_str.dimmed());
    }

    Ok(())
}

fn run_command_exit_on_error(
    command: &[&str],
    directory: &Path,
    dry_run: bool,
) -> Result<()> {
    let command_string = command.join(" ");

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            command_string.dimmed()
        );
    } else {
        println!("  {} {}", "⠿".cyan(), command_string.dimmed());

        let status = Command::new(command[0])
            .args(&command[1..])
            .current_dir(directory)
            .status()
            .with_context(|| format!("Failed to execute command: {command_string}"))?;

        if !status.success() {
            let exit_code = status.code().unwrap_or(-1);
            eprintln!(
                "  {} Exit code {} for {}",
                "✗".bold().red(),
                exit_code.to_string().red(),
                command_string.dimmed()
            );
            anyhow::bail!("Command failed with exit code {exit_code}");
        }

        println!("  {} Done", "✓".bold().green());
    }

    Ok(())
}
