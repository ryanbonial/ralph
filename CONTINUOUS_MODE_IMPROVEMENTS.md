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

## Solution 3: Docker Setup for Safe Continuous Mode

### Quick Start Docker Wrapper

Create `ralph-docker.sh`:

```bash
#!/bin/bash
# Run Ralph in Docker container for safe continuous mode

# Build image if not exists
if ! docker images | grep -q "ralph-env"; then
    echo "Building Ralph Docker environment..."
    docker build -t ralph-env -f- . <<'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    jq

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Claude CLI (optional - configure as needed)
# RUN npm install -g @anthropic-ai/claude-cli

WORKDIR /workspace
CMD ["/bin/bash"]
EOF
fi

# Run Ralph in container
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "$HOME/.cursor:/root/.cursor:ro" \
    -e "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" \
    -e "RUN_MODE=${RUN_MODE:-continuous}" \
    -e "MAX_ITERATIONS=${MAX_ITERATIONS:-100}" \
    ralph-env \
    /workspace/ralph.sh "$@"
```

Make it executable:
```bash
chmod +x ralph-docker.sh
```

Usage:
```bash
# Run in Docker continuous mode
./ralph-docker.sh

# Or specify iterations
MAX_ITERATIONS=50 ./ralph-docker.sh
```

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
