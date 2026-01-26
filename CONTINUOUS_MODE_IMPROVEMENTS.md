# Continuous Mode Improvements for Ralph

## Issue: Double CTRL-C Required

When running Ralph in continuous mode, users often need to press CTRL-C twice to exit cleanly. This happens because there are two processes:
1. The bash loop (`ralph.sh`)
2. The AI agent (Claude/Cursor)

## Solution 1: Add Signal Handling

Add this code to `ralph.sh` after the configuration section (around line 50):

```bash
# Graceful shutdown handling
SHUTDOWN_REQUESTED=false

handle_shutdown() {
    log_warning "Shutdown requested by user..."
    SHUTDOWN_REQUESTED=true
    
    # Kill any running child processes
    if [ -n "$AGENT_PID" ]; then
        log_info "Stopping agent (PID: $AGENT_PID)..."
        kill -TERM "$AGENT_PID" 2>/dev/null || true
        wait "$AGENT_PID" 2>/dev/null || true
    fi
    
    log_info "Ralph will exit after current iteration"
    exit 130
}

trap handle_shutdown SIGINT SIGTERM
```

Then modify the `run_continuous_loop()` function to check for shutdown:

```bash
run_continuous_loop() {
    for iteration in $(seq 1 $MAX_ITERATIONS); do
        # Check if shutdown was requested
        if [ "$SHUTDOWN_REQUESTED" = true ]; then
            log_warning "Exiting due to user interrupt"
            exit 130
        fi
        
        # ... rest of the loop
    done
}
```

And in `execute_agent()`, capture the PID:

```bash
execute_agent() {
    log_info "Running agent (mode: $AI_AGENT_MODE)..."

    case "$AI_AGENT_MODE" in
        claude)
            log_info "Using Claude CLI..."
            if command -v claude &> /dev/null; then
                cat "$AGENT_PROMPT_FILE" | claude &
                AGENT_PID=$!
                wait $AGENT_PID
            # ... rest of cases
            ;;
    esac
}
```

## Solution 2: Permission Handling for Continuous Mode

### Option A: Pre-Flight Permission Check

Add a pre-flight check before the loop starts:

```bash
# In check_prerequisites() function
check_prerequisites() {
    # ... existing checks ...
    
    if [ "$RUN_MODE" = "continuous" ]; then
        log_info "Continuous mode detected - checking permissions setup..."
        echo ""
        log_warning "For smooth continuous operation, consider:"
        echo "  1. Pre-approve common permissions in Cursor settings"
        echo "  2. Run in Docker container (see CONTINUOUS_MODE_IMPROVEMENTS.md)"
        echo "  3. Use human-in-the-loop mode for better control"
        echo ""
        read -p "Continue with continuous mode? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Switching to human-in-the-loop mode"
            RUN_MODE="once"
        fi
    fi
}
```

### Option B: Document Permission Requirements

Create a `.ralph/required-permissions.txt` that the agent can reference:

```
# Required Permissions for This Project

The following permissions are typically needed:
- network: For npm/pip package installation
- git_write: For creating commits (Ralph blocks push by default)

Optional permissions:
- all: Only if you need access to ignored files or special syscalls

Safety note: Ralph prevents git push by default. To enable:
  ALLOW_GIT_PUSH=true ./ralph.sh
```

## Solution 3: Docker Setup for Safe Continuous Mode (✅ IMPLEMENTED)

Ralph now includes `ralph-docker.sh` - a production-ready Docker wrapper for completely sandboxed execution.

### Why Use Docker?

**Security Benefits:**
- ✅ **Isolated Environment**: Ralph runs in a container with NO access to your host system
- ✅ **Volume-Only Access**: Only your project directory and read-only .cursor config are mounted
- ✅ **No Permission Prompts**: Docker bypasses IDE permission systems entirely
- ✅ **Clean Interrupts**: `docker stop` or CTRL-C works cleanly (no double CTRL-C issue)
- ✅ **Reproducible Environment**: Same Ubuntu 22.04 base, Node.js 20.x, Python 3, jq on every run

**When to Use:**
- Running Ralph overnight or on remote servers
- Maximum security for untrusted/experimental code
- Avoiding permission prompt interruptions in continuous mode
- Ensuring consistent environment across different machines

### Quick Start

```bash
# First time: Docker will build the image (takes ~2 minutes)
./ralph-docker.sh

# Subsequent runs: Uses cached image (starts immediately)
./ralph-docker.sh

# Force rebuild (e.g., after updating dependencies)
REBUILD=true ./ralph-docker.sh

# Limit iterations
MAX_ITERATIONS=50 ./ralph-docker.sh

# Human-in-the-loop mode in Docker
RUN_MODE=once ./ralph-docker.sh
```

### Configuration

Environment variables you can pass to Docker:

```bash
# Core settings
ANTHROPIC_API_KEY=your-key    # Required for Claude CLI
RUN_MODE=continuous           # Default: continuous (or use 'once')
MAX_ITERATIONS=100            # Default: 100

# Ralph settings (same as ralph.sh)
AI_AGENT_MODE=claude          # claude, cursor, or aider
LOG_LEVEL=INFO                # DEBUG, INFO, WARN, ERROR
TEST_OUTPUT_MODE=failures     # full, failures, summary

# Docker settings
DOCKER_IMAGE_NAME=ralph-env   # Custom image name
DOCKER_IMAGE_TAG=latest       # Custom image tag
REBUILD=false                 # Force image rebuild
```

### What's In The Docker Image

The `ralph-env` image includes:

- **Base**: Ubuntu 22.04 LTS
- **Runtime**: Node.js 20.x, Python 3, Bash
- **Tools**: git, curl, jq, npm
- **Optional**: Claude CLI (commented out - uncomment in Dockerfile if needed)

To customize the image, edit the Dockerfile section in `ralph-docker.sh` and set `REBUILD=true`.

### Volume Mounts

Ralph Docker mounts exactly two directories:

1. **Project Directory** (read-write): `-v $(pwd):/workspace`
   - Your code, .ralph/ directory, and git repository
   - Ralph can create commits, but git push is blocked by default

2. **.cursor Config** (read-only): `-v $HOME/.cursor:/root/.cursor:ro`
   - Allows Ralph to use your Cursor API keys if needed
   - Read-only for security

**NOT mounted**: Your home directory, system files, other projects - Ralph has zero access to these.

### Usage Examples

```bash
# Standard continuous mode (recommended)
./ralph-docker.sh

# Run with custom iterations
MAX_ITERATIONS=20 ./ralph-docker.sh

# Debug mode with verbose logging
LOG_LEVEL=DEBUG ./ralph-docker.sh

# Test a single iteration
RUN_MODE=once ./ralph-docker.sh

# Force rebuild after updating Dockerfile
REBUILD=true ./ralph-docker.sh
```

### Stopping Ralph

```bash
# From the same terminal: Press CTRL-C once
# Docker handles cleanup automatically

# From another terminal:
docker ps                    # Find the container ID
docker stop <container-id>   # Stops cleanly

# Nuclear option (not recommended):
docker kill <container-id>   # Force kill
```

### Troubleshooting

**Docker not found:**
```bash
# macOS
brew install --cask docker

# Ubuntu/Debian
sudo apt-get install docker.io

# Then start Docker Desktop or daemon
```

**Permission denied:**
```bash
# Linux: Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

**Image build fails:**
```bash
# Check Docker has internet access
docker run --rm ubuntu:22.04 curl -I https://deb.nodesource.com

# Clear Docker cache and rebuild
docker system prune -a
REBUILD=true ./ralph-docker.sh
```

**Git commits not persisting:**
- The project directory is mounted read-write
- Commits ARE persisted to your host
- Check you're not on a protected branch (main/master)

**Tests fail in Docker:**
- Tests run in the same environment as development
- If tests pass locally but fail in Docker, check for:
  - Missing system dependencies in Dockerfile
  - Path assumptions (use absolute paths)
  - Environment variable differences

## Solution 4: Graceful Exit on Completion

Modify the completion check to exit more cleanly:

```bash
check_completion() {
    local incomplete_count=$(grep -c '"passes": false' "$PRD_FILE" || true)

    if [ "$incomplete_count" -eq 0 ]; then
        log_success "All features complete!"
        echo "  🎓 \"I'm learnding!\" - Ralph Wiggum"
        echo ""
        
        # In continuous mode, exit cleanly
        if [ "$RUN_MODE" = "continuous" ]; then
            log_success "Continuous mode complete - exiting"
            exit 0
        fi
        
        return 0
    else
        log_info "Remaining features: $incomplete_count"
        return 1
    fi
}
```

## Recommended Setup

For the best experience with continuous mode:

1. **Start with human-in-the-loop** to understand the workflow
2. **Set up Docker** if you want truly autonomous operation
3. **Add signal handling** to ralph.sh for cleaner interrupts
4. **Work on feature branches** (Ralph enforces this by default)
5. **Review Ralph's built-in safety features**:
   - Protected branches (main/master blocked)
   - No push by default (ALLOW_GIT_PUSH=false)
   - Auto-rollback on test failures
   - Quality gates (linting, formatting, tests)

## Example: Safe Continuous Mode Setup

```bash
# 1. Create feature branch (Ralph auto-creates if on main/master)
git checkout -b feature/my-feature

# 2. Run in human-in-the-loop first
./ralph.sh
# Review changes
./ralph.sh
# Review again
./ralph.sh

# 3. Once confident, switch to continuous
RUN_MODE=continuous ./ralph.sh

# 4. Or use Docker for maximum safety
./ralph-docker.sh
```

## Troubleshooting

### Still Need Double CTRL-C?
- Add the signal handling from Solution 1
- Or run in Docker where you can `docker stop` the container

### Permission Prompts Interrupting?
- Pre-approve common permissions in Cursor
- Or use Docker to avoid permission system entirely
- Or stick with human-in-the-loop mode

### Agent Not Exiting When Done?
- Check that agent outputs "PROMISE COMPLETE"
- Verify check_completion() is being called
- Add logging to debug where loop hangs

## References

- Ralph prevents accidental damage with built-in safety features
- Protected branches and no-push-by-default keep your main branch safe
- Docker provides an additional safety layer for autonomous operation
