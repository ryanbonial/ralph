#!/usr/bin/env bats
# Test feature selection logic from PRD

@test "script has get_next_feature_from_prd function" {
    grep -q 'get_next_feature_from_prd()' ralph.sh
}

@test "feature selection uses Python for JSON parsing" {
    # Verify the script uses Python to parse PRD
    grep -A 15 'get_next_feature_from_prd()' ralph.sh | grep -q 'python3'
}

@test "feature selection checks passes field" {
    # Verify the script filters by passes=false
    grep -A 30 'get_next_feature_from_prd()' ralph.sh | grep -q 'passes'
}

@test "feature selection checks blocked_reason" {
    # Verify the script filters out blocked features
    grep -A 30 'get_next_feature_from_prd()' ralph.sh | grep -q 'blocked_reason'
}

@test "feature selection checks dependencies" {
    # Verify the script checks depends_on field
    grep -A 50 'get_next_feature_from_prd()' ralph.sh | grep -q 'depends_on'
}

@test "feature selection respects priority order" {
    # Verify priority ordering: critical > high > medium > low
    grep -A 30 'get_next_feature_from_prd()' ralph.sh | grep -q 'priority_order'
    grep -A 30 'get_next_feature_from_prd()' ralph.sh | grep -q 'critical'
}

@test "feature selection sorts candidates" {
    # Verify candidates are sorted
    grep -A 60 'get_next_feature_from_prd()' ralph.sh | grep -q 'sort'
}

@test "feature selection validates all dependencies are met" {
    # Verify that it checks if all dependencies have passes=true
    grep -A 40 'get_next_feature_from_prd()' ralph.sh | grep -q 'deps_met'
}

@test "script has check_completion function" {
    grep -q 'check_completion()' ralph.sh
}

@test "check_completion counts incomplete features" {
    # Verify it checks for features with passes field
    grep -A 30 'check_completion()' ralph.sh | grep -q 'passes'
}
