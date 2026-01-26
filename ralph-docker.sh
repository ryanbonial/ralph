#!/bin/bash
# Ralph Wiggum Docker Wrapper - Sandboxed Execution Mode
#
# Run Ralph in a Docker container for enhanced security and isolation.
# This prevents Ralph from accessing your host system beyond the project directory.
#
# Usage:
#   ./ralph-docker.sh                    # Run with default settings
#   MAX_ITERATIONS=50 ./ralph-docker.sh  # Limit iterations
#   REBUILD=true ./ralph-docker.sh       # Force rebuild of Docker image

set -euo pipefail

# Configuration
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-ralph-env}"
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-latest}"
REBUILD="${REBUILD:-false}"
RALPH_SCRIPT="${RALPH_SCRIPT:-ralph.sh}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[Ralph Docker]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[Ralph Docker]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[Ralph Docker]${NC} $*"
}

log_error() {
    echo -e "${RED}[Ralph Docker]${NC} $*" >&2
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed!"
        echo ""
        echo "Please install Docker:"
        echo "  macOS:   brew install --cask docker"
        echo "  Linux:   https://docs.docker.com/engine/install/"
        echo "  Windows: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running!"
        echo ""
        echo "Please start Docker Desktop or the Docker service."
        exit 1
    fi
}

# Check if Docker image exists
image_exists() {
    docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}$"
}

# Build Docker image
build_image() {
    log_info "Building Ralph Docker environment..."
    echo ""

    docker build -t "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" -f- . <<'EOF'
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify installations
RUN git --version && \
    python3 --version && \
    node --version && \
    npm --version && \
    jq --version

# Optional: Install Claude CLI (uncomment to enable)
# RUN npm install -g @anthropic-ai/claude-cli
# Note: You'll need to set ANTHROPIC_API_KEY environment variable

# Set up working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
EOF

    if [ $? -eq 0 ]; then
        log_success "Docker image built successfully: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
        echo ""
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Main execution
main() {
    log_info "Ralph Wiggum Docker Wrapper - Sandboxed Execution Mode"
    echo ""

    # Check prerequisites
    check_docker

    # Check if ralph.sh exists
    if [ ! -f "$RALPH_SCRIPT" ]; then
        log_error "Ralph script not found: $RALPH_SCRIPT"
        echo ""
        echo "Please run this script from the directory containing ralph.sh"
        exit 1
    fi

    # Build or rebuild image if needed
    if [ "$REBUILD" = "true" ]; then
        log_warning "REBUILD=true - forcing image rebuild"
        build_image
    elif ! image_exists; then
        log_info "Docker image not found, building..."
        build_image
    else
        log_success "Using existing Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
        log_info "To rebuild: REBUILD=true ./ralph-docker.sh"
        echo ""
    fi

    # Prepare environment variables
    ENV_VARS=""

    # Pass through ANTHROPIC_API_KEY if set
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        ENV_VARS="$ENV_VARS -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY"
    fi

    # Pass through RUN_MODE (default: continuous for Docker)
    RUN_MODE="${RUN_MODE:-continuous}"
    ENV_VARS="$ENV_VARS -e RUN_MODE=$RUN_MODE"

    # Pass through MAX_ITERATIONS (default: 100)
    MAX_ITERATIONS="${MAX_ITERATIONS:-100}"
    ENV_VARS="$ENV_VARS -e MAX_ITERATIONS=$MAX_ITERATIONS"

    # Pass through other Ralph configuration if set
    [ -n "${AI_AGENT_MODE:-}" ] && ENV_VARS="$ENV_VARS -e AI_AGENT_MODE=$AI_AGENT_MODE"
    [ -n "${LOG_LEVEL:-}" ] && ENV_VARS="$ENV_VARS -e LOG_LEVEL=$LOG_LEVEL"
    [ -n "${TEST_OUTPUT_MODE:-}" ] && ENV_VARS="$ENV_VARS -e TEST_OUTPUT_MODE=$TEST_OUTPUT_MODE"

    log_info "Starting Ralph in Docker container..."
    log_info "  Mode: $RUN_MODE"
    log_info "  Max iterations: $MAX_ITERATIONS"
    log_info "  Working directory: $(pwd)"
    echo ""
    log_info "Press CTRL-C to stop (Docker handles shutdown cleanly)"
    echo ""

    # Run Ralph in Docker container
    # shellcheck disable=SC2086
    docker run -it --rm \
        -v "$(pwd):/workspace" \
        -v "$HOME/.cursor:/root/.cursor:ro" \
        $ENV_VARS \
        "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" \
        /workspace/$RALPH_SCRIPT "$@"

    EXIT_CODE=$?

    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        log_success "Ralph completed successfully"
    elif [ $EXIT_CODE -eq 130 ]; then
        log_warning "Ralph interrupted by user (CTRL-C)"
    else
        log_error "Ralph exited with error code: $EXIT_CODE"
    fi

    exit $EXIT_CODE
}

# Run main function
main "$@"
