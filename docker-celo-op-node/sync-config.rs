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

const CONFIG_BASE_URL: &str =
    "https://raw.githubusercontent.com/celo-org/celo-l2-node-docker-compose/refs/heads/main/envs/mainnet/config";

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Sync configuration files for celo-op-node", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let script_dir = env::current_dir().context("Failed to get current directory")?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing config for".bold().cyan(),
        "celo-op-node".bold().green(),
    );
    println!("{}", "━".repeat(60).bright_black());

    download_file(
        &format!("{CONFIG_BASE_URL}/rollup.json"),
        &script_dir.join("config/rollup.json").to_string_lossy(),
        args.dry_run,
    )?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}

fn download_file(url: &str, dest: &str, dry_run: bool) -> Result<()> {
    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Downloading:".bold(),
        dest.yellow()
    );

    let mut cmd = Command::new("curl");
    cmd.arg("-fSL")
        .arg("--create-dirs")
        .arg("-o")
        .arg(dest)
        .arg(url);

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("{cmd:?}").dimmed()
        );
    } else {
        println!("  {} {}", "URL:".dimmed(), url.bright_white());

        let status = cmd
            .status()
            .with_context(|| format!("Failed to download {url}"))?;

        if !status.success() {
            eprintln!(
                "  {} Failed to download {}",
                "✗".bold().red(),
                dest.yellow()
            );
            anyhow::bail!("Download failed for {url}");
        }

        println!("  {} Downloaded {}", "✓".bold().green(), dest.yellow());
    }

    Ok(())
}
