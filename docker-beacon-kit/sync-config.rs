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

const BASE_URL: &str =
    "https://raw.githubusercontent.com/berachain/beacon-kit/refs/heads/main/testing/networks/80094";

const FILES: &[(&str, &str)] = &[
    ("app.toml", "config/app.toml"),
    ("client.toml", "config/client.toml"),
    ("config.toml", "config/config.toml"),
    ("genesis.json", "config/genesis.json"),
    ("kzg-trusted-setup.json", "config/kzg-trusted-setup.json"),
];

#[derive(Parser, Debug)]
#[command(name = "sync-config")]
#[command(about = "Download beacon-kit config files from berachain GitHub repository", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be downloaded without running
    #[arg(short = 'n', long)]
    dry_run: bool,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let work_dir = env::current_dir().context("Failed to get current directory")?;
    let config_dir = work_dir.join("config");

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {}",
        "Syncing".bold().cyan(),
        "beacon-kit config files".bold(),
    );
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{:>12} {}",
        "Source:".bold().blue(),
        BASE_URL.yellow()
    );
    println!(
        "{:>12} {}",
        "Target:".bold().blue(),
        config_dir.display().to_string().yellow()
    );
    println!("{}", "━".repeat(60).bright_black());

    if !config_dir.exists() {
        println!();
        println!(
            "{} {}",
            "→".bold().cyan(),
            "Creating config directory...".bold()
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
            println!("  {} Directory created", "✓".bold().green());
        }
    }

    for (remote_name, local_path) in FILES {
        let url = format!("{BASE_URL}/{remote_name}");
        let dest = work_dir.join(local_path);
        download_file(&url, &dest, args.dry_run, args.verbose)?;
    }

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Config sync completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();

    Ok(())
}

fn download_file(url: &str, dest: &Path, dry_run: bool, verbose: bool) -> Result<()> {
    let file_name = dest
        .file_name()
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_default();

    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Downloading:".bold(),
        file_name.yellow()
    );

    if verbose {
        println!("  {:>10} {}", "URL:".dimmed(), url.bright_white());
        println!(
            "  {:>10} {}",
            "Dest:".dimmed(),
            dest.display().to_string().bright_white()
        );
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("curl -L {url} -o {}", dest.display()).dimmed()
        );
        return Ok(());
    }

    let status = Command::new("curl")
        .arg("-L")
        .arg(url)
        .arg("-o")
        .arg(dest)
        .status()
        .with_context(|| format!("Failed to execute curl for {file_name}"))?;

    if !status.success() {
        eprintln!(
            "  {} Download failed for {}",
            "✗".bold().red(),
            file_name.yellow()
        );
        anyhow::bail!("Download failed for {file_name}");
    }

    println!("  {} Downloaded {}", "✓".bold().green(), file_name.yellow());

    Ok(())
}
