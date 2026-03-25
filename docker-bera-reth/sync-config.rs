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

const BASE_URL: &str =
    "https://raw.githubusercontent.com/berachain/beacon-kit/refs/heads/main/testing/networks/80094";

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Sync config files for bera-reth", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn download_file(url: &str, path: &str, dry_run: bool) -> Result<()> {
    println!(
        "  {} {} → {}",
        "→".bold().cyan(),
        url.dimmed(),
        path.bright_white()
    );

    if dry_run {
        println!(
            "    {} would download {} to {}",
            "[DRY RUN]".bold().yellow(),
            url.dimmed(),
            path.dimmed()
        );
        return Ok(());
    }

    let status = Command::new("curl")
        .arg("-L")
        .arg("-f")
        .arg("-s")
        .arg("-S")
        .arg(url)
        .arg("-o")
        .arg(path)
        .status()
        .with_context(|| format!("Failed to execute curl for {url}"))?;

    if !status.success() {
        eprintln!(
            "    {} Failed to download {}",
            "✗".bold().red(),
            url.yellow()
        );
        anyhow::bail!("Download failed: {url}");
    }

    println!("    {} Downloaded successfully", "✓".bold().green());

    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();

    let script_dir = env::current_dir().context("Failed to get current directory")?;
    let config_dir = script_dir.join("config/berachain");

    // Print header
    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing config for".bold().cyan(),
        "bera-reth".bold().green()
    );
    println!("{}", "━".repeat(60).bright_black());

    // Create config directory
    if !config_dir.exists() {
        println!(
            "  {} Creating directory: {}",
            "→".bold().cyan(),
            config_dir.display().to_string().bright_white()
        );
        if !args.dry_run {
            std::fs::create_dir_all(&config_dir)
                .with_context(|| format!("Failed to create directory: {}", config_dir.display()))?;
        }
    }

    // Download config files
    let files = [
        ("eth-genesis.json", "config/berachain/genesis.json"),
        ("el-bootnodes.txt", "config/berachain/el-bootnodes.txt"),
        ("el-peers.txt", "config/berachain/el-peers.txt"),
    ];

    for (remote, local) in &files {
        let url = format!("{BASE_URL}/{remote}");
        download_file(&url, local, args.dry_run)?;
    }

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}
