# containerctl - Docker Compose Container Management

A modern CLI utility for managing Docker Compose containers with a focus on simplicity and visual feedback.

## Prerequisites

- [rust-script](https://rust-script.org/) - Install with: `cargo install rust-script`
- Docker and Docker Compose

## Usage

### Restart a Container

Pulls the latest image, stops the container, and starts it again:

```bash
./containerctl.rs restart <container-name>
```

With log following:

```bash
./containerctl.rs restart <container-name> --follow
# or
./containerctl.rs restart <container-name> -f
```

### Stop a Container

Stops a running container:

```bash
./containerctl.rs stop <container-name>
```

## Examples

```bash
# Restart a container
./containerctl.rs restart geth

# Restart and follow logs
./containerctl.rs restart geth -f

# Stop a container
./containerctl.rs stop geth
```

## Commands

### restart

Performs the following steps:
1. Pulls the latest image (`docker compose pull <name>`)
2. Stops the container (`docker compose down <name>`)
3. Starts the container (`docker compose up -d <name>`)
4. Optionally follows logs (`docker logs -f <name>`)

Options:
- `-f, --follow`: Follow startup logs after restart

### stop

Stops a running container:
- Runs `docker compose down <name>`

## Features

- **Color-coded output**: Clear visual feedback with colors and symbols
- **Progress indicators**: Shows what's happening at each step (⠿, ✓, ✗, →)
- **Error handling**: Exits immediately on errors with clear messages
- **Log following**: Optional `-f` flag to follow container logs after restart

## Migration from Kotlin Script

### Old way:
```bash
./containerctl.main.kts restart geth -f
./containerctl.main.kts stop geth
```

### New way:
```bash
./containerctl.rs restart geth -f
./containerctl.rs stop geth
```

The commands and flags are identical!

## Using with Cargo (Optional)

If you prefer to use `cargo run`:

```bash
cargo run --bin containerctl -- restart geth
cargo run --bin containerctl -- stop geth
```

## Output Examples

### Restart Command

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Restarting container: geth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Pulling latest image...
  ⠿ docker compose pull geth
  ✓ Image pulled

→ Stopping container...
  ⠿ docker compose down geth
  ✓ Container stopped

→ Starting container...
  ⠿ docker compose up -d geth
  ✓ Container started

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Restart completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Stop Command

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stopping container: geth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Stopping container...
  ⠿ docker compose down geth
  ✓ Container stopped

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Stop completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
