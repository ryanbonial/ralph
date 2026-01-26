#!/usr/bin/env bats
# Test git safety features: protected branches and push blocking

@test "script has is_protected_branch function" {
    grep -q 'is_protected_branch()' ralph.sh
}

@test "script checks for protected branches" {
    grep -q 'PROTECTED_BRANCHES' ralph.sh
}

@test "script has git push safety check" {
    grep -q 'ALLOW_GIT_PUSH' ralph.sh
}

@test "script has check_for_git_push function" {
    grep -q 'check_for_git_push' ralph.sh
}

@test "script warns about protected branch commits" {
    grep -q 'Cannot run Ralph on protected branch' ralph.sh
}

@test "script suggests creating feature branch" {
    grep -q 'git checkout -b feature/' ralph.sh
}

@test "PROTECTED_BRANCHES includes main and master by default" {
    result=$(grep 'PROTECTED_BRANCHES="\${PROTECTED_BRANCHES:-' ralph.sh | head -1)
    echo "$result" | grep -q 'main'
    echo "$result" | grep -q 'master'
}

@test "ALLOW_GIT_PUSH defaults to false for safety" {
    grep -q 'ALLOW_GIT_PUSH="\${ALLOW_GIT_PUSH:-false}"' ralph.sh
}

@test "AUTO_CREATE_BRANCH feature exists" {
    grep -q 'AUTO_CREATE_BRANCH=' ralph.sh
}

@test "script has auto_create_feature_branch function" {
    grep -q 'auto_create_feature_branch()' ralph.sh
}

@test "script can generate branch names from features" {
    grep -q 'generate_branch_name()' ralph.sh
}

@test "branch names include feature type prefix" {
    # Check that the script generates prefixes like feature/, bugfix/, etc
    grep -q 'prefix="feature"' ralph.sh
    grep -q 'prefix="bugfix"' ralph.sh
}
