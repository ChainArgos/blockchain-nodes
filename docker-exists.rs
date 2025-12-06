#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1.0"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.8"
//! clap = { version = "4.5", features = ["derive"] }
//! reqwest = { version = "0.12", features = ["blocking", "json"] }
//! ```

use anyhow::{Context, Result};
use clap::Parser;
use serde::Deserialize;
use std::env;

#[derive(Debug, Deserialize)]
struct BuildConfig {
    package: PackageConfig,
    docker: DockerConfig,
}

#[derive(Debug, Deserialize)]
struct PackageConfig {
    #[allow(dead_code)]
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
}

#[derive(Debug, Deserialize)]
struct DockerConfig {
    repository: String,
    #[allow(dead_code)]
    platforms: Vec<String>,
}

#[derive(Parser, Debug)]
#[command(name = "docker-exists")]
#[command(about = "Check if a Docker image exists on Docker Hub", long_about = None)]
struct Args {
    /// Package name to check (e.g., "geth", "bitcoin-core")
    package: Option<String>,

    /// Platform to check (e.g., "amd64", "arm64"). If not specified, checks the manifest tag.
    #[arg(short, long)]
    platform: Option<String>,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

fn main() -> Result<()> {
    let args = Args::parse();

    // Determine the build directory
    let build_dir = if let Some(package) = &args.package {
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

    // Determine the tag to check
    let tag = if let Some(platform) = &args.platform {
        // Check platform-specific tag (e.g., "1.16.7-1-amd64")
        format!("{}-{}", config.package.full_version(), platform)
    } else {
        // Check manifest tag (e.g., "1.16.7-1")
        config.package.full_version()
    };

    if args.verbose {
        eprintln!("Checking if {}:{} exists...", config.docker.repository, tag);
    }

    let exists = check_image_exists(&config.docker.repository, &tag, args.verbose)?;

    if exists {
        if args.verbose {
            eprintln!("✓ Image exists: {}:{}", config.docker.repository, tag);
        }
        println!("true");
        std::process::exit(0);
    } else {
        if args.verbose {
            eprintln!("✗ Image not found: {}:{}", config.docker.repository, tag);
        }
        println!("false");
        std::process::exit(0);
    }
}

fn check_image_exists(repository: &str, tag: &str, verbose: bool) -> Result<bool> {
    // Docker Hub API endpoint for tags
    // Format: https://hub.docker.com/v2/repositories/{namespace}/{repository}/tags/{tag}

    let parts: Vec<&str> = repository.split('/').collect();
    if parts.len() != 2 {
        anyhow::bail!("Invalid repository format. Expected format: namespace/repository (e.g., donbeave/geth)");
    }

    let namespace = parts[0];
    let repo_name = parts[1];

    // Use the Docker Hub API to check if the tag exists
    let url = format!(
        "https://hub.docker.com/v2/repositories/{}/{}/tags/{}",
        namespace, repo_name, tag
    );

    if verbose {
        eprintln!("API URL: {}", url);
    }

    let client = reqwest::blocking::Client::builder()
        .user_agent("docker-exists/1.0")
        .build()
        .context("Failed to create HTTP client")?;

    let response = client
        .get(&url)
        .send()
        .context("Failed to send HTTP request")?;

    if verbose {
        eprintln!("HTTP Status: {}", response.status());
    }

    // If we get a 200 OK, the tag exists
    // If we get a 404 Not Found, the tag doesn't exist
    match response.status().as_u16() {
        200 => Ok(true),
        404 => Ok(false),
        status => {
            let error_text = response
                .text()
                .unwrap_or_else(|_| String::from("Unknown error"));
            anyhow::bail!("Unexpected HTTP status {}: {}", status, error_text)
        }
    }
}
