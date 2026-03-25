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

const BASE_URL: &str = "https://raw.githubusercontent.com/maticnetwork/bor/refs/heads/master/packaging/templates/mainnet-v1/sentry/sentry/bor";

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Sync config files from the Polygon bor repository", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn download_file(url: &str, dest: &str, dry_run: bool) -> Result<()> {
    println!(
        "  {} {} → {}",
        "→".bold().cyan(),
        url.dimmed(),
        dest.bright_white()
    );

    if dry_run {
        println!(
            "  {} Would download {} → {}",
            "[DRY RUN]".bold().yellow(),
            url.dimmed(),
            dest.bright_white()
        );
        return Ok(());
    }

    let status = Command::new("curl")
        .arg("-sSfL")
        .arg("-o")
        .arg(dest)
        .arg(url)
        .status()
        .with_context(|| format!("Failed to execute curl for {url}"))?;

    if !status.success() {
        anyhow::bail!("Failed to download {url}");
    }

    println!("  {} Downloaded {}", "✓".bold().green(), dest.bright_white());

    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();

    let script_dir = env::current_dir().context("Failed to get current directory")?;

    // Print header
    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing config for".bold().cyan(),
        "bor".bold().green()
    );
    println!("{}", "━".repeat(60).bright_black());

    // Ensure config directory exists
    let config_dir = script_dir.join("config");
    if !config_dir.exists() {
        std::fs::create_dir_all(&config_dir)
            .with_context(|| format!("Failed to create directory: {}", config_dir.display()))?;
    }

    // Download config files
    download_file(
        &format!("{BASE_URL}/pbss_config.toml"),
        config_dir.join("config.toml").to_str().unwrap(),
        args.dry_run,
    )?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}
