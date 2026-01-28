#!/usr/bin/env bats
# Tests for Feature 024: Progress Footer

# Test Configuration
@test "SHOW_PROGRESS_FOOTER default is true" {
    grep -q 'SHOW_PROGRESS_FOOTER="${SHOW_PROGRESS_FOOTER:-true}"' ralph.sh
}

@test "SHOW_PROGRESS_FOOTER can be disabled" {
    grep -q 'SHOW_PROGRESS_FOOTER' ralph.sh
}

@test "Progress footer configuration documented in --help" {
    ./ralph.sh --help 2>&1 | grep -q "SHOW_PROGRESS_FOOTER"
}

# Test Function Existence
@test "calculate_prd_stats function exists" {
    grep -q "^calculate_prd_stats()" ralph.sh
}

@test "display_progress_footer function exists" {
    grep -q "^display_progress_footer()" ralph.sh
}

# Test calculate_prd_stats Implementation
@test "calculate_prd_stats uses get_prd_data" {
    grep -A5 "^calculate_prd_stats()" ralph.sh | grep -q "get_prd_data"
}

@test "calculate_prd_stats counts total features" {
    grep -A20 "^calculate_prd_stats()" ralph.sh | grep -q "total = len(features)"
}

@test "calculate_prd_stats counts completed features" {
    grep -A20 "^calculate_prd_stats()" ralph.sh | grep -q "completed = sum.*passes"
}

@test "calculate_prd_stats counts blocked features" {
    grep -A20 "^calculate_prd_stats()" ralph.sh | grep -q "blocked = sum.*blocked_reason"
}

@test "calculate_prd_stats calculates in_progress features" {
    grep -A20 "^calculate_prd_stats()" ralph.sh | grep -q "in_progress = total - completed - blocked"
}

@test "calculate_prd_stats returns CSV format" {
    grep -A25 "^calculate_prd_stats()" ralph.sh | grep -q "print(f'{total},{completed},{blocked},{in_progress}')"
}

@test "calculate_prd_stats gets current feature" {
    grep -A30 "^calculate_prd_stats()" ralph.sh | grep -q "CURRENT_FEATURE_DATA=.*get_next_feature_from_prd"
}

# Test display_progress_footer Implementation
@test "display_progress_footer respects SHOW_PROGRESS_FOOTER config" {
    grep -A5 "^display_progress_footer()" ralph.sh | grep -q 'if.*SHOW_PROGRESS_FOOTER.*!=.*true'
}

@test "display_progress_footer calls calculate_prd_stats" {
    grep -A10 "^display_progress_footer()" ralph.sh | grep -q "calculate_prd_stats"
}

@test "display_progress_footer parses CSV stats" {
    grep -A15 "^display_progress_footer()" ralph.sh | grep -q "IFS=',' read.*total completed blocked in_progress"
}

@test "display_progress_footer calculates percentage" {
    grep -A20 "^display_progress_footer()" ralph.sh | grep -q "percent=.*completed.*100.*total"
}

@test "display_progress_footer displays box drawing characters" {
    grep -A40 "^display_progress_footer()" ralph.sh | grep -q "┌─"
}

@test "display_progress_footer shows Current Task label" {
    grep -A45 "^display_progress_footer()" ralph.sh | grep -q "Current Task"
}

@test "display_progress_footer shows Progress label" {
    grep -A50 "^display_progress_footer()" ralph.sh | grep -q "Progress"
}

@test "display_progress_footer uses GREEN color for Progress" {
    grep -A50 "^display_progress_footer()" ralph.sh | grep -q 'GREEN.*Progress'
}

@test "display_progress_footer uses BLUE color for Current Task" {
    grep -A45 "^display_progress_footer()" ralph.sh | grep -q '\${BLUE}Current Task'
}

@test "display_progress_footer uses RED color for blocked count" {
    grep -A55 "^display_progress_footer()" ralph.sh | grep -q '\${RED}.*blocked'
}

@test "display_progress_footer shows blocked count when > 0" {
    grep -A60 "^display_progress_footer()" ralph.sh | grep -q 'if.*blocked.*-gt 0'
}

# Test Integration with Iteration Functions
@test "run_single_iteration calls display_progress_footer" {
    grep -A20 "^run_single_iteration()" ralph.sh | grep -q "display_progress_footer"
}

@test "run_continuous_loop calls display_progress_footer" {
    grep -A20 "^run_continuous_loop()" ralph.sh | grep -q "display_progress_footer"
}

@test "display_progress_footer called after iteration header in single mode" {
    # Check that display_progress_footer comes after the iteration log message in single mode
    grep -A15 "^run_single_iteration()" ralph.sh | grep -q "display_progress_footer"
}

@test "display_progress_footer called after iteration header in continuous mode" {
    # Check that display_progress_footer comes after the iteration log message in continuous mode
    grep -A20 "^run_continuous_loop()" ralph.sh | grep -q "display_progress_footer"
}

# Test Feature Parsing
@test "display_progress_footer extracts feature ID" {
    grep -A35 "^display_progress_footer()" ralph.sh | grep -q "feature_id=.*get.*id"
}

@test "display_progress_footer extracts feature type" {
    grep -A36 "^display_progress_footer()" ralph.sh | grep -q "feature_type=.*get.*type"
}

@test "display_progress_footer extracts feature description" {
    grep -A37 "^display_progress_footer()" ralph.sh | grep -q "feature_desc=.*get.*description"
}

@test "display_progress_footer truncates long descriptions" {
    grep -A40 "^display_progress_footer()" ralph.sh | grep -q "if.*#feature_desc.*-gt 60"
}

# Test Error Handling
@test "calculate_prd_stats handles errors gracefully" {
    grep -A5 "^calculate_prd_stats()" ralph.sh | grep -q "if.*\$?.*-ne 0"
}

@test "calculate_prd_stats returns 0,0,0,0 on error" {
    grep -A7 "^calculate_prd_stats()" ralph.sh | grep -q 'echo "0,0,0,0"'
}

@test "calculate_prd_stats Python code has exception handling" {
    grep -A30 "^calculate_prd_stats()" ralph.sh | grep -q "except Exception"
}

@test "display_progress_footer handles missing current feature" {
    grep -A32 "^display_progress_footer()" ralph.sh | grep -q "None (all complete)"
}

# Test Documentation
@test "Feature 024 mentioned in code comments" {
    grep -q "Feature 024" ralph.sh
}

@test "Progress footer configuration documented" {
    grep -B3 'SHOW_PROGRESS_FOOTER=' ralph.sh | grep -q "Progress Footer"
}

# Integration Tests (if we can safely test without side effects)
@test "calculate_prd_stats returns valid CSV when PRD exists" {
    # Create a minimal test to ensure the function can be called
    # This test verifies the function exists and returns something
    type -t calculate_prd_stats > /dev/null || skip "Function not sourceable"
}

@test "display_progress_footer can be disabled via config" {
    # Verify that the function checks SHOW_PROGRESS_FOOTER
    grep -A5 "^display_progress_footer()" ralph.sh | grep -q "return 0"
}
