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
#[command(about = "Download BSC mainnet config files from GitHub releases", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Args {
    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let current_dir = env::current_dir().context("Failed to get current directory")?;
    let config_dir = current_dir.join("config");

    let config = read_build_config(&current_dir)?;
    let version = &config.package.version;
    let download_url = format!(
        "https://github.com/bnb-chain/bsc/releases/download/v{version}/mainnet.zip"
    );

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {} {}",
        "Syncing".bold().cyan(),
        "bsc-geth config files".bold(),
        format!("v{version}").dimmed(),
    );
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{:>12} {}",
        "Source:".bold().blue(),
        download_url.yellow()
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

    download_file(&download_url, &current_dir, args.dry_run, args.verbose)?;
    unzip_file(&current_dir, args.dry_run, args.verbose)?;
    move_file(
        &current_dir.join("mainnet/config.toml"),
        &config_dir.join("config.toml"),
        args.dry_run,
        args.verbose,
    )?;
    move_file(
        &current_dir.join("mainnet/genesis.json"),
        &config_dir.join("genesis.json"),
        args.dry_run,
        args.verbose,
    )?;
    cleanup(&current_dir, args.dry_run, args.verbose)?;

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

fn download_file(url: &str, work_dir: &Path, dry_run: bool, verbose: bool) -> Result<()> {
    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Downloading:".bold(),
        "mainnet.zip".yellow()
    );

    if verbose {
        println!("  {:>10} {}", "URL:".dimmed(), url.bright_white());
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("curl -L {url} -o mainnet.zip").dimmed()
        );
        return Ok(());
    }

    let status = Command::new("curl")
        .arg("-L")
        .arg(url)
        .arg("-o")
        .arg("mainnet.zip")
        .current_dir(work_dir)
        .status()
        .context("Failed to execute curl")?;

    if !status.success() {
        eprintln!("  {} Download failed", "✗".bold().red());
        anyhow::bail!("Download failed for mainnet.zip");
    }

    println!("  {} Downloaded {}", "✓".bold().green(), "mainnet.zip".yellow());

    Ok(())
}

fn unzip_file(work_dir: &Path, dry_run: bool, verbose: bool) -> Result<()> {
    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Extracting mainnet.zip...".bold()
    );

    if verbose {
        println!(
            "  {:>10} {}",
            "Dir:".dimmed(),
            work_dir.display().to_string().bright_white()
        );
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            "unzip mainnet.zip".dimmed()
        );
        return Ok(());
    }

    let status = Command::new("unzip")
        .arg("-o")
        .arg("mainnet.zip")
        .current_dir(work_dir)
        .status()
        .context("Failed to execute unzip")?;

    if !status.success() {
        eprintln!("  {} Extraction failed", "✗".bold().red());
        anyhow::bail!("Failed to unzip mainnet.zip");
    }

    println!("  {} Extracted {}", "✓".bold().green(), "mainnet.zip".yellow());

    Ok(())
}

fn move_file(src: &Path, dest: &Path, dry_run: bool, verbose: bool) -> Result<()> {
    let file_name = dest
        .file_name()
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_default();

    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Moving:".bold(),
        file_name.yellow()
    );

    if verbose {
        println!(
            "  {:>10} {}",
            "From:".dimmed(),
            src.display().to_string().bright_white()
        );
        println!(
            "  {:>10} {}",
            "To:".dimmed(),
            dest.display().to_string().bright_white()
        );
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("mv {} {}", src.display(), dest.display()).dimmed()
        );
        return Ok(());
    }

    std::fs::rename(src, dest)
        .with_context(|| format!("Failed to move {} to {}", src.display(), dest.display()))?;

    println!("  {} Moved {}", "✓".bold().green(), file_name.yellow());

    Ok(())
}

fn cleanup(work_dir: &Path, dry_run: bool, verbose: bool) -> Result<()> {
    let zip_path = work_dir.join("mainnet.zip");
    let dir_path = work_dir.join("mainnet");

    println!();
    println!(
        "{} {}",
        "→".bold().cyan(),
        "Cleaning up...".bold()
    );

    if verbose {
        println!("  {:>10} {}", "Remove:".dimmed(), "mainnet.zip".bright_white());
        println!("  {:>10} {}", "Remove:".dimmed(), "mainnet/".bright_white());
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            "rm mainnet.zip".dimmed()
        );
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            "rm -rf mainnet/".dimmed()
        );
        return Ok(());
    }

    std::fs::remove_file(&zip_path)
        .with_context(|| format!("Failed to remove {}", zip_path.display()))?;
    println!("  {} Removed {}", "✓".bold().green(), "mainnet.zip".yellow());

    std::fs::remove_dir_all(&dir_path)
        .with_context(|| format!("Failed to remove {}", dir_path.display()))?;
    println!("  {} Removed {}", "✓".bold().green(), "mainnet/".yellow());

    Ok(())
}
