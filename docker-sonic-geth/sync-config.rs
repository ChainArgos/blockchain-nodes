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

const BASE_URL: &str = "https://genesis.soniclabs.com/sonic-mainnet/genesis";

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Sync config files for sonic-geth", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let base_dir = env::current_dir().context("Failed to get current directory")?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing config for".bold().cyan(),
        "sonic-geth".bold().green(),
    );
    println!("{}", "━".repeat(60).bright_black());

    download_file(
        &format!("{BASE_URL}/sonic.g"),
        &base_dir.join("config/sonic.g"),
        args.dry_run,
    )?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();
    Ok(())
}

fn download_file(
    url: &str,
    dest: &std::path::Path,
    dry_run: bool,
) -> Result<()> {
    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Downloading".bold(),
        dest.file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .yellow()
    );
    println!("  {:>6} {}", "URL:".dimmed(), url.bright_white());
    println!(
        "  {:>6} {}",
        "Dest:".dimmed(),
        dest.display().to_string().bright_white()
    );

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            "Skipping download".dimmed()
        );
        return Ok(());
    }

    if let Some(parent) = dest.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("Failed to create directory: {}", parent.display()))?;
    }

    let status = Command::new("curl")
        .arg("-fSL")
        .arg("-o")
        .arg(dest)
        .arg(url)
        .status()
        .context("Failed to execute curl")?;

    if !status.success() {
        eprintln!("  {} Download failed", "✗".bold().red());
        anyhow::bail!("Failed to download {url}");
    }

    println!("  {} Downloaded successfully", "✓".bold().green());
    Ok(())
}
