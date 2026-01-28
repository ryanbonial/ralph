#!/usr/bin/env bats

# Tests for feature 025: Prevent confusing commit messages with premature test claims
# Bug: Claude writes "All X tests pass" in commits BEFORE Ralph verifies tests
# Fix: AGENT_PROMPT.md must forbid test result claims in commit messages

# Test 1: AGENT_PROMPT.md section 9 should forbid test result claims
@test "AGENT_PROMPT.md forbids test result claims in commit messages" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "NEVER.*Claim.*Test"
}

# Test 2: AGENT_PROMPT.md should explain WHY test claims are forbidden
@test "AGENT_PROMPT.md explains why test claims are forbidden" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "Ralph verifies tests"
}

# Test 3: AGENT_PROMPT.md should provide BAD commit message examples
@test "AGENT_PROMPT.md shows BAD commit message examples with test claims" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "All.*tests pass"
}

# Test 4: AGENT_PROMPT.md should provide GOOD commit message examples
@test "AGENT_PROMPT.md shows GOOD commit message examples without test claims" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "GOOD.*commit messages"
}

# Test 5: AGENT_PROMPT.md should have WARNING about test claims
@test "AGENT_PROMPT.md has WARNING section about test claims" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "WARNING"
}

# Test 6: AGENT_PROMPT.md should emphasize describing WHAT, not test status
@test "AGENT_PROMPT.md emphasizes describing implementation, not test results" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "WHAT you implemented"
}

# Test 7: Check that commit message guidance section exists
@test "AGENT_PROMPT.md has Create Git Commit section" {
  grep -q "### 9. Create Git Commit" AGENT_PROMPT.md
}

# Test 8: AGENT_PROMPT.md should mention contradictory output problem
@test "AGENT_PROMPT.md mentions contradictory output problem" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "contradict"
}

# Test 9: AGENT_PROMPT.md should forbid specific test count claims
@test "AGENT_PROMPT.md forbids test count claims like '235 tests pass'" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "All 235 tests pass"
}

# Test 10: AGENT_PROMPT.md explains Ralph reports test status separately
@test "AGENT_PROMPT.md explains Ralph reports test status separately" {
  grep -A60 "Create Git Commit" AGENT_PROMPT.md | grep -iq "Ralph will report test status"
}
