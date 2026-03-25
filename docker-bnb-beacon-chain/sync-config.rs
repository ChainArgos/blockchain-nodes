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
#[command(about = "Download and sync BNB Beacon Chain config files", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn run_command(cmd: &mut Command, description: &str, dry_run: bool) -> Result<()> {
    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("{cmd:?}").dimmed()
        );
    } else {
        let status = cmd
            .status()
            .with_context(|| format!("Failed to execute: {description}"))?;

        if !status.success() {
            eprintln!("  {} {}", "✗".bold().red(), description);
            anyhow::bail!("{description}");
        }

        println!("  {} {}", "✓".bold().green(), description);
    }

    Ok(())
}

fn move_file(src: &Path, dst: &Path, dry_run: bool) -> Result<()> {
    let description = format!("{} → {}", src.display(), dst.display());

    if dry_run {
        println!(
            "  {} move {}",
            "[DRY RUN]".bold().yellow(),
            description.dimmed()
        );
    } else {
        if let Some(parent) = dst.parent() {
            std::fs::create_dir_all(parent)
                .with_context(|| format!("Failed to create directory: {}", parent.display()))?;
        }

        std::fs::rename(src, dst)
            .with_context(|| format!("Failed to move {description}"))?;

        println!("  {} {}", "✓".bold().green(), description);
    }

    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();

    let current_dir = env::current_dir().context("Failed to get current directory")?;

    // Read and parse build.toml
    let config_path = current_dir.join("build.toml");
    let config_content = std::fs::read_to_string(&config_path)
        .with_context(|| format!("Failed to read config file: {}", config_path.display()))?;

    let config: BuildConfig =
        toml::from_str(&config_content).context("Failed to parse build.toml")?;

    let version = &config.package.version;
    let download_url = format!(
        "https://github.com/bnb-chain/node/releases/download/v{version}/mainnet_config.zip"
    );
    let zip_file = "mainnet_config.zip";

    // Print header
    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {} {}",
        "Syncing config for".bold().cyan(),
        config.package.name.bold().green(),
        format!("v{version}").dimmed()
    );
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{:>12} {}",
        "Version:".bold().blue(),
        version.yellow()
    );
    println!(
        "{:>12} {}",
        "URL:".bold().blue(),
        download_url.dimmed()
    );
    println!("{}", "━".repeat(60).bright_black());

    // Step 1: Download mainnet_config.zip
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Downloading mainnet_config.zip".bold()
    );
    run_command(
        Command::new("curl")
            .arg("-L")
            .arg("-o")
            .arg(zip_file)
            .arg(&download_url)
            .current_dir(&current_dir),
        "Downloaded mainnet_config.zip",
        args.dry_run,
    )?;

    // Step 2: Unzip
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Extracting archive".bold()
    );
    run_command(
        Command::new("unzip")
            .arg("-o")
            .arg(zip_file)
            .current_dir(&current_dir),
        "Extracted mainnet_config.zip",
        args.dry_run,
    )?;

    // Step 3: Move config files
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Moving config files".bold()
    );
    move_file(
        &current_dir.join("asset/mainnet/config.toml"),
        &current_dir.join("config/config.toml"),
        args.dry_run,
    )?;
    move_file(
        &current_dir.join("asset/mainnet/app.toml"),
        &current_dir.join("config/app.toml"),
        args.dry_run,
    )?;
    move_file(
        &current_dir.join("asset/mainnet/genesis.json"),
        &current_dir.join("config/genesis.json"),
        args.dry_run,
    )?;

    // Step 4: Clean up
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Cleaning up".bold()
    );

    if args.dry_run {
        println!(
            "  {} remove {}",
            "[DRY RUN]".bold().yellow(),
            zip_file.dimmed()
        );
        println!(
            "  {} remove {}",
            "[DRY RUN]".bold().yellow(),
            "asset/".dimmed()
        );
    } else {
        std::fs::remove_file(current_dir.join(zip_file))
            .with_context(|| format!("Failed to remove {zip_file}"))?;
        println!("  {} Removed {}", "✓".bold().green(), zip_file);

        std::fs::remove_dir_all(current_dir.join("asset"))
            .context("Failed to remove asset/ directory")?;
        println!("  {} Removed {}", "✓".bold().green(), "asset/");
    }

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}
