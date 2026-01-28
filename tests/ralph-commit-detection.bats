#!/usr/bin/env bats

# Tests for Feature 027: Fix false success detection when Claude interrupted before real work

@test "ralph.sh has commit timestamp checking logic" {
    grep -q "ITERATION_START_TIME" ralph.sh
}

@test "ralph.sh records iteration start time before executing agent" {
    # Check that we set ITERATION_START_TIME before execute_agent
    awk '/^run_single_iteration\(\)/,/^}/' ralph.sh | grep -q "ITERATION_START_TIME"
}

@test "ralph.sh checks commit timestamp against iteration start time" {
    # Should get commit timestamp and compare it
    grep -q "git.*--format.*%ct\|committer-date" ralph.sh
}

@test "ralph.sh only reports success for commits made in current iteration" {
    # Should have logic that compares commit time to iteration start
    grep -A10 "git log -1" ralph.sh | grep -q "ITERATION_START_TIME\|timestamp\|epoch"
}

@test "ralph.sh detects if commit is from current iteration" {
    # Should check if commit was made after iteration started
    grep -A20 "Commit detected" ralph.sh | grep -q "iteration\|timestamp\|current"
}

@test "ralph.sh does not claim success for old commits" {
    # When commit is older than iteration start, should not report success
    # This is the key bug: currently reports success even for old commits
    # After fix, should have conditional logic checking commit age

    # Check for conditional around "Commit detected" message
    # After fix, there should be timestamp comparison before reporting success
    awk '/LAST_COMMIT_MESSAGE=/,/Commit detected/' ralph.sh | grep -q "if.*ITERATION_START_TIME\|if.*timestamp"
}

@test "ralph.sh warns when no new commits made in iteration" {
    # Should distinguish between "no commit" and "old commit"
    # After fix, should warn if commit exists but is too old
    grep -q "No new commit in this iteration\|last commit is from previous work" ralph.sh
}

@test "run_single_iteration captures start time" {
    # run_single_iteration should set ITERATION_START_TIME
    awk '/^run_single_iteration\(\)/,/^}/' ralph.sh | grep -q "ITERATION_START_TIME.*date.*epoch\|ITERATION_START_TIME.*%s"
}

@test "run_continuous_loop captures start time for each iteration" {
    # run_continuous_loop should set ITERATION_START_TIME in the loop
    awk '/^run_continuous_loop\(\)/,/^}/' ralph.sh | grep -q "ITERATION_START_TIME.*date.*epoch\|ITERATION_START_TIME.*%s"
}

@test "commit detection verifies work was done in current iteration" {
    # The key fix: verify commit is from THIS iteration, not a previous one
    # Look for comparison logic after getting LAST_COMMIT_MESSAGE

    # After fix, should have something like:
    # COMMIT_TIME=$(git log -1 --format=%ct)
    # if [ "$COMMIT_TIME" -gt "$ITERATION_START_TIME" ]; then

    # Check that we get commit timestamp
    grep -q "git.*log.*--format.*%ct\|git.*log.*--format=%at" ralph.sh
}

@test "commit detection documentation explains timestamp checking" {
    # After fix, there should be a comment explaining the timestamp check
    grep -B5 -A5 "ITERATION_START_TIME" ralph.sh | grep -q "#.*iteration\|#.*timestamp\|#.*current"
}

@test "ITERATION_START_TIME is set before execute_agent in both modes" {
    # Check single iteration mode
    awk '/^run_single_iteration\(\)/,/execute_agent/' ralph.sh | grep -q "ITERATION_START_TIME"

    # Check continuous loop mode
    awk '/^run_continuous_loop\(\)/,/execute_agent/' ralph.sh | tail -20 | grep -q "ITERATION_START_TIME"
}
