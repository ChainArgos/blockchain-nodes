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
use clap::Parser;
use owo_colors::OwoColorize;
use serde::Deserialize;
use std::collections::HashMap;
use std::env;
use std::path::Path;
use std::process::Command;

#[derive(Debug, Deserialize)]
struct BuildConfig {
    package: PackageConfig,
    docker: DockerConfig,
    #[serde(default)]
    vars: std::collections::HashMap<String, String>,
}

#[derive(Debug, Deserialize)]
struct PackageConfig {
    name: String,
    version: String,
    build: Option<String>,
}

impl PackageConfig {
    /// Get the full version string (version-build)
    fn full_version(&self) -> String {
        if let Some(build) = &self.build {
            format!("{}-{}", self.version, build)
        } else {
            self.version.clone()
        }
    }

    /// Get the build argument name from package name (e.g., "wbt-geth" -> "WBT_GETH_VERSION")
    fn build_arg_name(&self) -> String {
        self.name.to_uppercase().replace('-', "_") + "_VERSION"
    }
}

#[derive(Debug, Deserialize)]
struct DockerConfig {
    repository: String,
    platforms: Vec<String>,
}

#[derive(Parser, Debug)]
#[command(name = "build")]
#[command(about = "Build Docker images for blockchain nodes", long_about = None)]
struct Args {
    /// Package name to build (e.g., "geth", "bitcoin-core")
    package: Option<String>,

    /// Extra arguments to pass to docker buildx build
    #[arg(short = 'e', long, default_value = "--progress plain")]
    extra_args: String,

    /// Dry run - show what would be executed without running
    #[arg(short = 'n', long)]
    dry_run: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    // Determine the build directory
    let build_dir = if let Some(package) = args.package {
        // Get the directory of the script
        let script_dir = env::current_dir().context("Failed to get current directory")?;
        script_dir.join(format!("docker-{}", package))
    } else {
        env::current_dir().context("Failed to get current directory")?
    };

    // Read and parse build.toml
    let config_path = build_dir.join("build.toml");
    let config_content = std::fs::read_to_string(&config_path)
        .with_context(|| format!("Failed to read config file: {}", config_path.display()))?;

    let config: BuildConfig =
        toml::from_str(&config_content).context("Failed to parse build.toml")?;

    // Print header
    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{} {} {}",
        "Building".bold().cyan(),
        config.package.name.bold().green(),
        format!("v{}", config.package.full_version()).dimmed()
    );
    println!("{}", "━".repeat(60).bright_black());
    println!(
        "{:>12} {}",
        "Repository:".bold().blue(),
        config.docker.repository.yellow()
    );
    println!(
        "{:>12} {}",
        "Platforms:".bold().blue(),
        config.docker.platforms.join(", ").magenta()
    );
    if !config.vars.is_empty() {
        println!(
            "{:>12} {}",
            "Variables:".bold().blue(),
            config
                .vars
                .keys()
                .map(|k| k.as_str())
                .collect::<Vec<_>>()
                .join(", ")
                .cyan()
        );
    }
    println!("{}", "━".repeat(60).bright_black());

    // Get GITHUB_TOKEN from environment if available
    let github_token = env::var("GITHUB_TOKEN").ok();
    if github_token.is_some() {
        println!("{:>12} {}", "Auth:".bold().blue(), "GITHUB_TOKEN".green());
    }

    // Build for each platform
    for platform in &config.docker.platforms {
        build_platform(
            &build_dir,
            &config,
            platform,
            &args.extra_args,
            github_token.as_deref(),
            args.dry_run,
        )?;
    }

    create_manifest(&config, args.dry_run)?;

    println!();
    println!("{}", "━".repeat(60).bright_black());
    println!("{}", "✓ Build completed successfully!".bold().green());
    println!("{}", "━".repeat(60).bright_black());
    println!();
    Ok(())
}

fn build_platform(
    build_dir: &Path,
    config: &BuildConfig,
    platform: &str,
    extra_args: &str,
    github_token: Option<&str>,
    dry_run: bool,
) -> Result<()> {
    let platform_tag = format!(
        "{}:{}-{}",
        config.docker.repository,
        config.package.full_version(),
        platform
    );

    let dockerfile_path = format!("Dockerfile.{}", platform);

    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Building for platform:".bold(),
        platform.yellow()
    );
    println!("  {:>10} {}", "Tag:".dimmed(), platform_tag.bright_white());
    println!(
        "  {:>10} {}",
        "Dockerfile:".dimmed(),
        dockerfile_path.bright_white()
    );

    let mut cmd = Command::new("docker");
    cmd.arg("buildx").arg("build").current_dir(build_dir);

    // Add extra args
    for arg in extra_args.split_whitespace() {
        cmd.arg(arg);
    }

    cmd.arg("--pull")
        .arg("--push")
        .arg("--provenance=false")
        .arg("--platform")
        .arg(format!("linux/{}", platform))
        .arg("-t")
        .arg(&platform_tag)
        .arg("-f")
        .arg(&dockerfile_path);

    // Add GITHUB_TOKEN as build arg if available
    if let Some(token) = github_token {
        cmd.arg("--build-arg")
            .arg(format!("GITHUB_TOKEN={}", token));
    }

    // Add version as build arg (e.g., WBT_GETH_VERSION=1.2.0)
    let version_arg_name = config.package.build_arg_name();
    cmd.arg("--build-arg")
        .arg(format!("{}={}", version_arg_name, config.package.version));

    // Add custom variables as build args (e.g., GIT_COMMIT=b9f3a3d9)
    for (key, value) in &config.vars {
        let build_arg_name = key.to_uppercase();
        cmd.arg("--build-arg")
            .arg(format!("{}={}", build_arg_name, value));
    }

    cmd.arg(".");

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("{:?}", cmd).dimmed()
        );
    } else {
        let spinner = format!("  {} Building...", "⠿".cyan());
        println!("{}", spinner);

        let status = cmd
            .status()
            .with_context(|| format!("Failed to execute docker build for {}", platform))?;

        if !status.success() {
            eprintln!(
                "  {} Docker build failed for platform {}",
                "✗".bold().red(),
                platform.yellow()
            );
            anyhow::bail!("Docker build failed for platform {}", platform);
        }

        println!(
            "  {} Build completed for {}",
            "✓".bold().green(),
            platform.yellow()
        );
    }

    Ok(())
}

fn create_manifest(config: &BuildConfig, dry_run: bool) -> Result<()> {
    let manifest_tag = format!(
        "{}:{}",
        config.docker.repository,
        config.package.full_version()
    );

    println!();
    println!(
        "{} {} {}",
        "→".bold().cyan(),
        "Creating manifest:".bold(),
        manifest_tag.yellow()
    );

    // Build list of platform-specific tags
    let platform_tags: Vec<String> = config
        .docker
        .platforms
        .iter()
        .map(|p| {
            format!(
                "{}:{}-{}",
                config.docker.repository,
                config.package.full_version(),
                p
            )
        })
        .collect();

    // Create manifest
    let mut create_cmd = Command::new("docker");
    create_cmd
        .arg("manifest")
        .arg("create")
        .arg("-a")
        .arg(&manifest_tag);

    for tag in &platform_tags {
        create_cmd.arg(tag);
    }

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("{:?}", create_cmd).dimmed()
        );
    } else {
        println!("  {} Creating manifest...", "⠿".cyan());
        let status = create_cmd.status().context("Failed to create manifest")?;

        if !status.success() {
            eprintln!("  {} Manifest creation failed", "✗".bold().red());
            anyhow::bail!("Manifest creation failed");
        }
        println!("  {} Manifest created", "✓".bold().green());
    }

    // Push manifest
    let mut push_cmd = Command::new("docker");
    push_cmd
        .arg("manifest")
        .arg("push")
        .arg("-p")
        .arg(&manifest_tag);

    if dry_run {
        println!(
            "  {} {}",
            "[DRY RUN]".bold().yellow(),
            format!("{:?}", push_cmd).dimmed()
        );
    } else {
        println!("  {} Pushing manifest...", "⠿".cyan());
        let status = push_cmd.status().context("Failed to push manifest")?;

        if !status.success() {
            eprintln!("  {} Manifest push failed", "✗".bold().red());
            anyhow::bail!("Manifest push failed");
        }
        println!("  {} Manifest pushed", "✓".bold().green());
    }

    Ok(())
}
