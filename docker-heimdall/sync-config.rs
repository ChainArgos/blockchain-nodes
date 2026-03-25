#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1.0"
//! clap = { version = "4.5", features = ["derive"] }
//! owo-colors = { version = "4.1", features = ["supports-colors"] }
//! ```

use anyhow::{Context, Result};
use clap::builder::styling::{AnsiColor, Effects, Styles};
use clap::Parser;
use owo_colors::OwoColorize;
use std::env;
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

    let script_dir = env::current_dir().context("Failed to get current directory")?;

    let config_dir = script_dir.join("config");

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing config for".bold().cyan(),
        "heimdall".bold().green(),
    );
    println!("{}", "━".repeat(60).bright_black());

    // Create config directory
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Creating config directory...".bold()
    );
    if args.dry_run {
        println!(
            "  {} mkdir -p {}",
            "[DRY RUN]".bold().yellow(),
            config_dir.display().to_string().dimmed()
        );
    } else {
        std::fs::create_dir_all(&config_dir)
            .with_context(|| format!("Failed to create directory: {}", config_dir.display()))?;
        println!("  {} Directory ready", "✓".bold().green());
    }

    // Download genesis file
    let genesis_path = config_dir.join("genesis.json");
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Downloading genesis file...".bold()
    );
    download_file(GENESIS_URL, &genesis_path, args.dry_run)?;

    // Compress genesis file
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Compressing genesis file...".bold()
    );
    run_command_exit_on_error(
        &["xz", "-9", &genesis_path.to_string_lossy()],
        &script_dir,
        args.dry_run,
    )?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}

fn download_file(url: &str, path: &std::path::Path, dry_run: bool) -> Result<()> {
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
    directory: &std::path::Path,
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
