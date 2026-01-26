#!/usr/bin/env bats
# Test ralph.sh configuration loading and defaults

@test "ralph.sh script exists and is executable" {
    [ -f "ralph.sh" ]
    [ -x "ralph.sh" ] || chmod +x ralph.sh
}

@test "ralph.sh has valid bash syntax" {
    bash -n ralph.sh
}

@test "MAX_ITERATIONS default value is 100" {
    grep -q 'MAX_ITERATIONS=\${MAX_ITERATIONS:-100}' ralph.sh
}

@test "RUN_MODE default value is once" {
    grep -q 'RUN_MODE="\${RUN_MODE:-once}"' ralph.sh
}

@test "AI_AGENT_MODE default value is claude" {
    grep -q 'AI_AGENT_MODE="\${AI_AGENT_MODE:-claude}"' ralph.sh
}

@test "PROTECTED_BRANCHES default includes main,master" {
    grep -q 'PROTECTED_BRANCHES="\${PROTECTED_BRANCHES:-main,master}"' ralph.sh
}

@test "ALLOW_GIT_PUSH default value is false" {
    grep -q 'ALLOW_GIT_PUSH="\${ALLOW_GIT_PUSH:-false}"' ralph.sh
}

@test "AUTO_CREATE_BRANCH default value is true" {
    grep -q 'AUTO_CREATE_BRANCH="\${AUTO_CREATE_BRANCH:-true}"' ralph.sh
}

@test "ROLLBACK_ON_FAILURE default value is true" {
    grep -q 'ROLLBACK_ON_FAILURE="\${ROLLBACK_ON_FAILURE:-true}"' ralph.sh
}

@test "VERIFY_BEFORE_COMPLETE default value is true" {
    grep -q 'VERIFY_BEFORE_COMPLETE="\${VERIFY_BEFORE_COMPLETE:-true}"' ralph.sh
}

@test "AUTOFIX_PRETTIER default value is true" {
    grep -q 'AUTOFIX_PRETTIER="\${AUTOFIX_PRETTIER:-true}"' ralph.sh
}

@test "PRD_STORAGE default value is file" {
    grep -q 'PRD_STORAGE="\${PRD_STORAGE:-file}"' ralph.sh
}

@test "PRD_FILE default is .ralph/prd.json" {
    grep -q 'PRD_FILE="\${PRD_FILE:-.ralph/prd.json}"' ralph.sh
}

@test "PROGRESS_FILE default is .ralph/progress.txt" {
    grep -q 'PROGRESS_FILE="\${PROGRESS_FILE:-.ralph/progress.txt}"' ralph.sh
}

@test "AGENT_PROMPT_FILE default is AGENT_PROMPT.md" {
    grep -q 'AGENT_PROMPT_FILE="\${AGENT_PROMPT_FILE:-AGENT_PROMPT.md}"' ralph.sh
}

@test "SLEEP_BETWEEN_ITERATIONS default is 5 seconds" {
    grep -q 'SLEEP_BETWEEN_ITERATIONS=\${SLEEP_BETWEEN_ITERATIONS:-5}' ralph.sh
}

@test "script includes is_protected_branch function" {
    grep -q '^is_protected_branch()' ralph.sh
}

@test "script includes get_next_feature_from_prd function" {
    grep -q '^get_next_feature_from_prd()' ralph.sh
}

@test "script includes check_prerequisites function" {
    grep -q '^check_prerequisites()' ralph.sh
}

@test "script includes run_verification_tests function" {
    grep -q '^run_verification_tests()' ralph.sh
}
