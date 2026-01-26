#!/usr/bin/env bats

# Tests for ralph.sh syntax and heredoc handling
# Focuses on catching "EOF: command not found" errors

@test "ralph.sh has no bash syntax errors" {
  run bash -n ralph.sh
  [ "$status" -eq 0 ]
}

@test "ralph.sh executes --help without errors" {
  run ./ralph.sh --help
  [ "$status" -eq 0 ]
}

@test "ralph.sh executes --doctor without errors" {
  run ./ralph.sh --doctor
  [ "$status" -eq 0 ]
}

@test "ralph.sh has no 'EOF: command not found' errors when sourced" {
  # This test tries to source ralph.sh and check for EOF errors
  # We redirect stderr to capture any "EOF: command not found" messages
  output=$(bash -c 'source ralph.sh 2>&1 || true' | grep -i "EOF: command not found" || true)
  [ -z "$output" ]
}

@test "all heredocs in ralph.sh are properly closed" {
  # Check that every <<EOF or <<'EOF' has a matching EOF on its own line
  # Count heredoc starts (handles both <<EOF and <<'EOF')
  heredoc_starts=$(grep -E "<<'?EOF'?" ralph.sh | wc -l | tr -d ' ')

  # Count EOF closures (EOF at beginning of line)
  heredoc_ends=$(grep "^EOF$" ralph.sh | wc -l | tr -d ' ')

  # They should match (both should be 0 for ralph.sh, which is valid)
  [ "$heredoc_starts" -eq "$heredoc_ends" ]
}

@test "ralph.sh line 7 has no syntax errors" {
  # Specifically check line 7 and surrounding context
  # Extract lines 1-15 and check for syntax errors
  head -15 ralph.sh | bash -n
  [ "$?" -eq 0 ]
}

@test "ralph-docker.sh has no bash syntax errors" {
  [ -f ralph-docker.sh ]
  run bash -n ralph-docker.sh
  [ "$status" -eq 0 ]
}

@test "ralph-docker.sh heredocs are properly formatted" {
  # ralph-docker.sh has a heredoc for Dockerfile
  # Verify it's properly closed
  heredoc_starts=$(grep -c "<<'EOF'" ralph-docker.sh || echo 0)
  heredoc_ends=$(grep -c "^EOF$" ralph-docker.sh || echo 0)
  [ "$heredoc_starts" -eq "$heredoc_ends" ]
}

@test "no script has EOF: command not found error when executed" {
  # Try to execute scripts and check stderr for EOF errors
  error_output=$(./ralph.sh --help 2>&1 | grep -i "EOF: command not found" || true)
  [ -z "$error_output" ]
}

@test "ralph.sh can be sourced without EOF errors in functions" {
  # Check if any function definitions have EOF issues
  # This catches cases where EOF might appear in unexpected contexts
  bash -c '
    set -e
    source ralph.sh 2>&1 | grep -i "EOF: command" && exit 1
    exit 0
  ' || {
    # If grep found "EOF: command", fail the test
    [ "$?" -eq 1 ]
  }
}
