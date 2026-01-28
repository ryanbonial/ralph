#!/usr/bin/env bats

# Tests for Feature 029: Persist failure context after rollback

setup() {
    # Source ralph.sh functions for testing
    source ralph.sh
}

# Test 1: log_failure_context function exists
@test "ralph.sh has log_failure_context function" {
    grep -q "^log_failure_context()" ralph.sh
}

# Test 2: log_failure_context is called after rollback in run_single_iteration
@test "run_single_iteration calls log_failure_context after rollback" {
    # Check that log_failure_context is called after rollback_last_commit
    grep -A 3 "rollback_last_commit" ralph.sh | grep -q "log_failure_context"
}

# Test 3: log_failure_context is called after rollback in run_continuous_loop
@test "run_continuous_loop calls log_failure_context after rollback" {
    # Check continuous loop also calls log_failure_context after rollback
    local count=$(grep -c "log_failure_context" ralph.sh)
    [ "$count" -ge 3 ]  # Function definition + 2 call sites
}

# Test 4: log_failure_context captures feature information
@test "log_failure_context extracts feature information from PRD" {
    # Check that function uses get_prd_data to fetch feature info
    grep -A 50 "^log_failure_context()" ralph.sh | grep -q "get_prd_data"
}

# Test 5: log_failure_context checks for formatting errors
@test "log_failure_context checks /tmp/ralph_format_check.log" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "/tmp/ralph_format_check.log"
}

# Test 6: log_failure_context checks for linting errors
@test "log_failure_context checks /tmp/ralph_lint.log" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "/tmp/ralph_lint.log"
}

# Test 7: log_failure_context checks for type checking errors
@test "log_failure_context checks /tmp/ralph_typecheck.log" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "/tmp/ralph_typecheck.log"
}

# Test 8: log_failure_context checks for test failures
@test "log_failure_context checks /tmp/ralph_test.log" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "/tmp/ralph_test.log"
}

# Test 9: log_failure_context uses extract_failing_tests for test errors
@test "log_failure_context uses extract_failing_tests function" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "extract_failing_tests"
}

# Test 10: log_failure_context appends to PROGRESS_FILE
@test "log_failure_context appends to progress file" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q ">> \"\$PROGRESS_FILE\""
}

# Test 11: log_failure_context creates ROLLBACK header
@test "log_failure_context writes ROLLBACK header with timestamp" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "ROLLBACK:"
}

# Test 12: log_failure_context includes feature ID
@test "log_failure_context includes feature ID in output" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "Feature:"
}

# Test 13: log_failure_context includes rolled back commit message
@test "log_failure_context includes rolled back commit message" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "Rolled Back Commit:"
}

# Test 14: log_failure_context lists failed quality gates
@test "log_failure_context lists failed quality gates" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "Failed Gates:"
}

# Test 15: log_failure_context provides guidance for next iteration
@test "log_failure_context provides guidance for next iteration" {
    grep -A 150 "^log_failure_context()" ralph.sh | grep -q "Next Iteration:"
}

# Test 16: log_failure_context passes commit message as parameter
@test "log_failure_context accepts commit message parameter" {
    # Check call sites pass LAST_COMMIT_MESSAGE
    grep "log_failure_context" ralph.sh | grep -v "^log_failure_context()" | grep -q "LAST_COMMIT_MESSAGE"
}

# Test 17: AGENT_PROMPT.md mentions ROLLBACK entries
@test "AGENT_PROMPT.md documents ROLLBACK entries" {
    grep -q "ROLLBACK" AGENT_PROMPT.md
}

# Test 18: AGENT_PROMPT.md tells agent to check for failure context
@test "AGENT_PROMPT.md instructs agent to check for ROLLBACK entries" {
    grep -A 5 "ROLLBACK" AGENT_PROMPT.md | grep -qE "(check|read|learn|failure)"
}

# Test 19: AGENT_PROMPT.md explains what ROLLBACK entries contain
@test "AGENT_PROMPT.md explains ROLLBACK entry contents" {
    grep -A 10 "ROLLBACK" AGENT_PROMPT.md | grep -qE "(quality gates|error|failure)"
}

# Test 20: log_failure_context captures error details from temp files
@test "log_failure_context captures error details not just gate names" {
    # Check that function reads content from temp files (tail, grep, etc)
    grep -A 150 "^log_failure_context()" ralph.sh | grep -qE "(tail|head|cat).*ralph_.*\.log"
}
