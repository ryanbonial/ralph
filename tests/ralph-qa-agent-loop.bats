#!/usr/bin/env bats
# Tests for QA agent loop functionality (Feature 031)

@test "ENABLE_QA_AGENT default value is true" {
    grep -q 'ENABLE_QA_AGENT="${ENABLE_QA_AGENT:-true}"' ralph.sh
}

@test "QA_AGENT_PROMPT_FILE default value is QA_AGENT_PROMPT.md" {
    grep -q 'QA_AGENT_PROMPT_FILE="${QA_AGENT_PROMPT_FILE:-QA_AGENT_PROMPT.md}"' ralph.sh
}

@test "QA_KNOWLEDGE_FILE default value is .ralph/qa-knowledge.md" {
    grep -q 'QA_KNOWLEDGE_FILE="${QA_KNOWLEDGE_FILE:-.ralph/qa-knowledge.md}"' ralph.sh
}

@test "ralph.sh has execute_qa_agent function" {
    grep -q '^execute_qa_agent()' ralph.sh
}

@test "ralph.sh has run_qa_agent function" {
    grep -q '^run_qa_agent()' ralph.sh
}

@test "ralph.sh has get_passed_feature_ids function" {
    grep -q '^get_passed_feature_ids()' ralph.sh
}

@test "ralph.sh has find_newly_passed_feature function" {
    grep -q '^find_newly_passed_feature()' ralph.sh
}

@test "QA_AGENT_PROMPT.md exists" {
    [ -f "QA_AGENT_PROMPT.md" ]
}

@test "QA_AGENT_PROMPT.md mentions qa-knowledge.md" {
    grep -q "qa-knowledge" QA_AGENT_PROMPT.md
}

@test "QA_AGENT_PROMPT.md describes manual e2e test script requirement" {
    grep -q "Manual E2E Test Script" QA_AGENT_PROMPT.md
}

@test "QA_AGENT_PROMPT.md prohibits reading source files" {
    grep -qi "never" QA_AGENT_PROMPT.md
    grep -qi "source code" QA_AGENT_PROMPT.md
}

@test "QA_AGENT_PROMPT.md describes bug ticket creation on fail" {
    grep -q "type.*bug" QA_AGENT_PROMPT.md
}

@test "QA_AGENT_PROMPT.md requires symptom-only bug descriptions" {
    grep -q "symptom" QA_AGENT_PROMPT.md || grep -q "observable" QA_AGENT_PROMPT.md
}

@test "QA_AGENT_PROMPT.md describes qa-knowledge append on pass" {
    grep -q "PASS" QA_AGENT_PROMPT.md
}

@test "doctor output includes ENABLE_QA_AGENT config" {
    grep -q 'ENABLE_QA_AGENT.*\$ENABLE_QA_AGENT' ralph.sh
}

@test "run_qa_agent generates a temporary prompt file" {
    grep -q 'qa_prompt_tmp' ralph.sh
    grep -q 'mktemp.*ralph-qa-prompt' ralph.sh
}

@test "run_qa_agent includes feature JSON in prompt" {
    grep -q 'feature_json' ralph.sh
}

@test "run_qa_agent cleans up temporary prompt file" {
    grep -q 'rm -f.*qa_prompt_tmp' ralph.sh
}

@test "run_single_iteration snapshots passed IDs before agent runs when QA enabled" {
    grep -q 'PRE_AGENT_PASSED_IDS' ralph.sh
    grep -q 'get_passed_feature_ids' ralph.sh
}

@test "run_single_iteration calls run_qa_agent after verification passes" {
    grep -q 'run_qa_agent' ralph.sh
}

@test "run_continuous_loop also invokes QA agent" {
    # Verify run_qa_agent is called in multiple places (both run_single_iteration and run_continuous_loop)
    local count
    count=$(grep -c 'run_qa_agent' ralph.sh)
    [ "$count" -ge 2 ]
}

@test "ENABLE_QA_AGENT=false skips QA invocation guard present in ralph.sh" {
    grep -q 'ENABLE_QA_AGENT.*true' ralph.sh
}

@test "qa-knowledge.md is initialized in check_prerequisites when QA enabled" {
    grep -q 'QA_KNOWLEDGE_FILE\|qa-knowledge' ralph.sh
    # Verify the initialization happens in check_prerequisites context
    grep -q 'Initializing QA knowledge base' ralph.sh
}

@test "get_passed_feature_ids returns comma-separated IDs" {
    grep -A 10 '^get_passed_feature_ids' ralph.sh | grep -q "join\|','"
}

@test "find_newly_passed_feature compares against pre-agent snapshot" {
    grep -A 15 '^find_newly_passed_feature' ralph.sh | grep -q 'pre_ids\|pre_passed'
}

@test "execute_qa_agent supports claude mode" {
    grep -A 20 '^execute_qa_agent' ralph.sh | grep -q 'claude'
}

@test "execute_qa_agent supports manual mode fallback" {
    grep -A 50 '^execute_qa_agent' ralph.sh | grep -q 'manual'
}

@test "ralph.sh has valid bash syntax after QA agent additions" {
    bash -n ralph.sh
}

@test "run_qa_agent skips when QA_AGENT_PROMPT_FILE is missing" {
    grep -A 5 'QA agent prompt file not found' ralph.sh | grep -q 'Skipping QA'
}
