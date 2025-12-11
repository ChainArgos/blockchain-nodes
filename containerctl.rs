#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1.0"
//! clap = { version = "4.5", features = ["derive"] }
//! owo-colors = { version = "4.1", features = ["supports-colors"] }
//! ```

use anyhow::{Context, Result};
use clap::builder::styling::{AnsiColor, Effects, Styles};
use clap::{Parser, Subcommand};
use owo_colors::OwoColorize;
use std::env;
use std::process::{Command, Stdio};

const HELP_STYLES: Styles = Styles::styled()
    .header(AnsiColor::Blue.on_default().effects(Effects::BOLD))
    .usage(AnsiColor::Blue.on_default().effects(Effects::BOLD))
    .literal(AnsiColor::Cyan.on_default().effects(Effects::BOLD))
    .placeholder(AnsiColor::Cyan.on_default())
    .error(AnsiColor::Red.on_default().effects(Effects::BOLD))
    .valid(AnsiColor::Green.on_default())
    .invalid(AnsiColor::Yellow.on_default());

#[derive(Parser, Debug)]
#[command(name = "containerctl")]
#[command(version = "1.0.0")]
#[command(about = "Docker Compose container management utility", long_about = None)]
#[command(styles = HELP_STYLES)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Restart a container (pull, down, up)
    Restart {
        /// Container name
        name: String,

        /// Follow startup logs
        #[arg(short = 'f', long)]
        follow: bool,
    },
    /// Stop a container
    Stop {
        /// Container name
        name: String,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    let current_dir = env::current_dir().context("Failed to get current directory")?;

    match cli.command {
        Commands::Restart { name, follow } => {
            println!();
            println!("{}", "━".repeat(60).bright_black());
            println!(
                "{} {} {}",
                "Restarting".bold().cyan(),
                "container:".bold(),
                name.yellow()
            );
            println!("{}", "━".repeat(60).bright_black());

            // Pull the latest image
            println!();
            println!("{} {}", "→".bold().cyan(), "Pulling latest image...".bold());
            run_command_exit_on_error(&["docker", "compose", "pull", &name], &current_dir)?;
            println!("  {} Image pulled", "✓".bold().green());

            // Stop the container
            println!();
            println!("{} {}", "→".bold().cyan(), "Stopping container...".bold());
            run_command(&["docker", "compose", "down", &name], &current_dir)?;
            println!("  {} Container stopped", "✓".bold().green());

            // Start the container
            println!();
            println!("{} {}", "→".bold().cyan(), "Starting container...".bold());
            run_command_exit_on_error(&["docker", "compose", "up", "-d", &name], &current_dir)?;
            println!("  {} Container started", "✓".bold().green());

            // Follow logs if requested
            if follow {
                println!();
                println!("{}", "━".repeat(60).bright_black());
                println!("{} {}", "Following logs for:".bold().cyan(), name.yellow());
                println!("{}", "━".repeat(60).bright_black());
                println!();
                run_command(&["docker", "logs", "-f", &name], &current_dir)?;
            } else {
                println!();
                println!("{}", "━".repeat(60).bright_black());
                println!("{}", "✓ Restart completed successfully!".bold().green());
                println!("{}", "━".repeat(60).bright_black());
                println!();
            }
        }
        Commands::Stop { name } => {
            println!();
            println!("{}", "━".repeat(60).bright_black());
            println!(
                "{} {} {}",
                "Stopping".bold().cyan(),
                "container:".bold(),
                name.yellow()
            );
            println!("{}", "━".repeat(60).bright_black());

            println!();
            println!("{} {}", "→".bold().cyan(), "Stopping container...".bold());
            run_command_exit_on_error(&["docker", "compose", "down", &name], &current_dir)?;
            println!("  {} Container stopped", "✓".bold().green());

            println!();
            println!("{}", "━".repeat(60).bright_black());
            println!("{}", "✓ Stop completed successfully!".bold().green());
            println!("{}", "━".repeat(60).bright_black());
            println!();
        }
    }

    Ok(())
}

fn run_command(command: &[&str], directory: &std::path::Path) -> Result<i32> {
    let command_string = command.join(" ");
    println!("  {} {}", "⠿".cyan(), command_string.dimmed());

    let mut cmd = Command::new(command[0]);
    cmd.args(&command[1..])
        .current_dir(directory)
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit());

    let status = cmd
        .status()
        .with_context(|| format!("Failed to execute command: {}", command_string))?;

    let exit_code = status.code().unwrap_or(-1);

    if exit_code != 0 {
        eprintln!(
            "  {} Exit code {} for {}",
            "✗".bold().red(),
            exit_code.to_string().red(),
            command_string.dimmed()
        );
    }

    Ok(exit_code)
}

fn run_command_exit_on_error(command: &[&str], directory: &std::path::Path) -> Result<()> {
    let exit_code = run_command(command, directory)?;

    if exit_code != 0 {
        anyhow::bail!("Command failed with exit code {}", exit_code);
    }

    Ok(())
}
