#!/usr/bin/env bats
# Tests for acceptance_criteria functionality in Ralph

@test "prd.json.template includes acceptance_criteria field" {
    grep -q '"acceptance_criteria"' prd.json.template
}

@test "prd.json.template acceptance_criteria has unit_tests array" {
    grep -q '"unit_tests"' prd.json.template
}

@test "prd.json.template acceptance_criteria has e2e_tests array" {
    grep -q '"e2e_tests"' prd.json.template
}

@test "prd.json.template acceptance_criteria has manual_checks array" {
    grep -q '"manual_checks"' prd.json.template
}

@test "prd.json.template field_definitions documents acceptance_criteria" {
    grep -q '"acceptance_criteria":.*unit_tests.*e2e_tests.*manual_checks' prd.json.template
}

@test "ralph.sh collects test files from acceptance_criteria" {
    grep -q "acceptance.get('unit_tests'" ralph.sh
    grep -q "acceptance.get('e2e_tests'" ralph.sh
}

@test "ralph.sh displays manual checks from acceptance_criteria" {
    grep -q "acceptance.get('manual_checks'" ralph.sh
}

@test "AGENT_PROMPT.md mentions acceptance_criteria" {
    grep -q "acceptance_criteria" AGENT_PROMPT.md
}

@test "AGENT_PROMPT.md documents unit_tests field" {
    grep -q "unit_tests" AGENT_PROMPT.md
}

@test "AGENT_PROMPT.md documents e2e_tests field" {
    grep -q "e2e_tests" AGENT_PROMPT.md
}

@test "AGENT_PROMPT.md documents manual_checks field" {
    grep -q "manual_checks" AGENT_PROMPT.md
}

@test "INITIALIZER_PROMPT.md includes acceptance_criteria in schema example" {
    grep -q '"acceptance_criteria"' INITIALIZER_PROMPT.md
}

@test "INITIALIZER_PROMPT.md documents acceptance_criteria usage" {
    grep -q "Acceptance Criteria" INITIALIZER_PROMPT.md
}

@test "README.md documents acceptance_criteria feature" {
    grep -q "Acceptance Criteria" README.md
}

@test "README.md shows acceptance_criteria structure" {
    grep -q '"acceptance_criteria"' README.md
}

@test "README.md explains acceptance_criteria benefits" {
    grep -A 4 "Benefits:" README.md | grep -q "Explicit test requirements"
}

@test "mock PRD fixture validates with acceptance_criteria" {
    # Create a temporary PRD with acceptance_criteria
    cat > /tmp/test-prd-acceptance.json <<EOF
{
  "project": "Test Project",
  "description": "Test",
  "schema_version": "2.0",
  "features": [
    {
      "id": "001",
      "type": "feature",
      "category": "functional",
      "priority": "high",
      "description": "Test feature",
      "steps": ["Step 1"],
      "estimated_complexity": "small",
      "depends_on": [],
      "passes": false,
      "iterations_taken": 0,
      "acceptance_criteria": {
        "unit_tests": ["tests/test.test.js"],
        "e2e_tests": ["tests/e2e/test.spec.js"],
        "manual_checks": ["Verify it works"]
      }
    }
  ]
}
EOF
    python3 -c "import json; json.load(open('/tmp/test-prd-acceptance.json'))"
    rm /tmp/test-prd-acceptance.json
}

@test "acceptance_criteria unit_tests are collected by ralph.sh" {
    # Verify the Python code in ralph.sh correctly accesses unit_tests
    grep -A 10 "acceptance.get('unit_tests'" ralph.sh | grep -q "all_tests.add"
}

@test "acceptance_criteria e2e_tests are collected by ralph.sh" {
    # Verify the Python code in ralph.sh correctly accesses e2e_tests
    grep -A 10 "acceptance.get('e2e_tests'" ralph.sh | grep -q "all_tests.add"
}

@test "acceptance_criteria manual checks displayed to user" {
    # Verify manual checks are formatted and displayed
    grep -q "Manual acceptance checks to verify" ralph.sh
}
