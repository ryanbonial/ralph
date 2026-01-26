#!/usr/bin/env bats
# Tests for ralph-docker.sh - Docker wrapper for sandboxed execution

# Test file existence and permissions
@test "ralph-docker.sh exists" {
    [ -f "ralph-docker.sh" ]
}

@test "ralph-docker.sh is executable" {
    [ -x "ralph-docker.sh" ]
}

@test "ralph-docker.sh has valid bash syntax" {
    bash -n ralph-docker.sh
}

# Test configuration variables
@test "ralph-docker.sh has DOCKER_IMAGE_NAME configuration" {
    grep -q 'DOCKER_IMAGE_NAME=' ralph-docker.sh
}

@test "ralph-docker.sh has DOCKER_IMAGE_TAG configuration" {
    grep -q 'DOCKER_IMAGE_TAG=' ralph-docker.sh
}

@test "ralph-docker.sh has REBUILD configuration" {
    grep -q 'REBUILD=' ralph-docker.sh
}

@test "DOCKER_IMAGE_NAME defaults to ralph-env" {
    grep -q 'DOCKER_IMAGE_NAME:-ralph-env' ralph-docker.sh
}

@test "DOCKER_IMAGE_TAG defaults to latest" {
    grep -q 'DOCKER_IMAGE_TAG:-latest' ralph-docker.sh
}

@test "REBUILD defaults to false" {
    grep -q 'REBUILD:-false' ralph-docker.sh
}

# Test helper functions
@test "ralph-docker.sh has check_docker function" {
    grep -q 'check_docker()' ralph-docker.sh
}

@test "ralph-docker.sh has image_exists function" {
    grep -q 'image_exists()' ralph-docker.sh
}

@test "ralph-docker.sh has build_image function" {
    grep -q 'build_image()' ralph-docker.sh
}

@test "ralph-docker.sh has log_info function" {
    grep -q 'log_info()' ralph-docker.sh
}

@test "ralph-docker.sh has log_success function" {
    grep -q 'log_success()' ralph-docker.sh
}

@test "ralph-docker.sh has log_warning function" {
    grep -q 'log_warning()' ralph-docker.sh
}

@test "ralph-docker.sh has log_error function" {
    grep -q 'log_error()' ralph-docker.sh
}

# Test Dockerfile content
@test "build_image uses Ubuntu 22.04 base" {
    grep -q 'FROM ubuntu:22.04' ralph-docker.sh
}

@test "build_image installs git" {
    grep -A10 'apt-get install' ralph-docker.sh | grep -q 'git'
}

@test "build_image installs curl" {
    grep -A10 'apt-get install' ralph-docker.sh | grep -q 'curl'
}

@test "build_image installs python3" {
    grep -A10 'apt-get install' ralph-docker.sh | grep -q 'python3'
}

@test "build_image installs jq" {
    grep -A10 'apt-get install' ralph-docker.sh | grep -q 'jq'
}

@test "build_image installs Node.js" {
    grep -q 'nodejs' ralph-docker.sh
}

@test "Dockerfile sets WORKDIR to /workspace" {
    grep -q 'WORKDIR /workspace' ralph-docker.sh
}

@test "build_image includes optional Claude CLI installation (commented)" {
    grep -q '# RUN npm install -g @anthropic-ai/claude-cli' ralph-docker.sh
}

# Test volume mounts
@test "docker run mounts current directory to /workspace" {
    grep -q '\-v "$(pwd):/workspace"' ralph-docker.sh
}

@test "docker run mounts .cursor config read-only" {
    grep -q '\-v "$HOME/.cursor:/root/.cursor:ro"' ralph-docker.sh
}

# Test environment variable passing
@test "docker run passes ANTHROPIC_API_KEY if set" {
    grep -q 'ANTHROPIC_API_KEY' ralph-docker.sh
}

@test "docker run passes RUN_MODE environment variable" {
    grep -q 'RUN_MODE=' ralph-docker.sh
}

@test "docker run passes MAX_ITERATIONS environment variable" {
    grep -q 'MAX_ITERATIONS=' ralph-docker.sh
}

@test "RUN_MODE defaults to continuous in Docker" {
    grep -q 'RUN_MODE:-continuous' ralph-docker.sh
}

@test "MAX_ITERATIONS defaults to 100 in Docker" {
    grep -q 'MAX_ITERATIONS:-100' ralph-docker.sh
}

# Test image caching logic
@test "script checks if image exists before building" {
    grep -q 'image_exists' ralph-docker.sh
}

@test "script can force rebuild with REBUILD=true" {
    grep -q 'REBUILD.*true' ralph-docker.sh
}

@test "script uses existing image if available" {
    grep -q 'Using existing Docker image' ralph-docker.sh
}

# Test Docker command structure
@test "docker run uses -it flags for interactive mode" {
    grep -q 'docker run -it' ralph-docker.sh
}

@test "docker run uses --rm to cleanup after exit" {
    grep -q 'docker run -it --rm' ralph-docker.sh
}

@test "docker run executes ralph.sh inside container" {
    grep -q '/workspace/\$RALPH_SCRIPT' ralph-docker.sh
}

# Test error handling
@test "script checks if Docker is installed" {
    grep -q 'command -v docker' ralph-docker.sh
}

@test "script checks if ralph.sh exists" {
    grep -q 'if \[ ! -f.*RALPH_SCRIPT' ralph-docker.sh
}

@test "script provides helpful error for missing Docker" {
    grep -A5 'Docker is not installed' ralph-docker.sh | grep -q 'Please install'
}

@test "script checks if Docker daemon is running" {
    grep -q 'docker info' ralph-docker.sh
}

# Test exit code handling
@test "script captures Docker exit code" {
    grep -q 'EXIT_CODE=' ralph-docker.sh
}

@test "script handles success exit code (0)" {
    grep -A1 'EXIT_CODE -eq 0' ralph-docker.sh | grep -q 'completed successfully'
}

@test "script handles interrupt exit code (130)" {
    grep -A1 'EXIT_CODE -eq 130' ralph-docker.sh | grep -q 'interrupted'
}

# Test documentation and usage
@test "script includes usage comment at top" {
    head -20 ralph-docker.sh | grep -q 'Usage:'
}

@test "script documents sandboxed execution purpose" {
    head -10 ralph-docker.sh | grep -q -i 'sandboxed\|isolation\|security'
}

@test "script shows rebuild instructions" {
    grep -q 'REBUILD=true' ralph-docker.sh
}
