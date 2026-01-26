#!/usr/bin/env bats
# Test PRD JSON parsing and validation

setup() {
    export TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        cd /
        rm -rf "$TEST_DIR"
    fi
}

@test "mock PRD fixture is valid JSON" {
    python3 -c "import json; json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))"
}

@test "mock PRD has required project field" {
    result=$(python3 -c "import json; data=json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json')); print(data.get('project', ''))")
    [ -n "$result" ]
}

@test "mock PRD has features array" {
    result=$(python3 -c "import json; data=json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json')); print(type(data.get('features', [])))")
    echo "$result" | grep -q 'list'
}

@test "mock PRD features have id field" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'id' in f, 'Missing id field'
"
}

@test "mock PRD features have type field" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'type' in f, 'Missing type field'
    assert f['type'] in ['feature', 'bug', 'refactor', 'test', 'spike'], f'Invalid type: {f[\"type\"]}'
"
}

@test "mock PRD features have priority field" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'priority' in f, 'Missing priority field'
    assert f['priority'] in ['critical', 'high', 'medium', 'low'], f'Invalid priority: {f[\"priority\"]}'
"
}

@test "mock PRD features have description field" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'description' in f, 'Missing description field'
    assert len(f['description']) > 0, 'Empty description'
"
}

@test "mock PRD features have depends_on field as array" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'depends_on' in f, 'Missing depends_on field'
    assert isinstance(f['depends_on'], list), 'depends_on must be array'
"
}

@test "mock PRD features have passes field as boolean" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'passes' in f, 'Missing passes field'
    assert isinstance(f['passes'], bool), 'passes must be boolean'
"
}

@test "mock PRD features have iterations_taken field as integer" {
    python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
for f in data['features']:
    assert 'iterations_taken' in f, 'Missing iterations_taken field'
    assert isinstance(f['iterations_taken'], int), 'iterations_taken must be integer'
    assert f['iterations_taken'] >= 0, 'iterations_taken must be non-negative'
"
}

@test "mock PRD has mix of complete and incomplete features" {
    result=$(python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
complete = sum(1 for f in data['features'] if f['passes'])
incomplete = sum(1 for f in data['features'] if not f['passes'])
print(f'{complete},{incomplete}')
")

    complete=$(echo "$result" | cut -d, -f1)
    incomplete=$(echo "$result" | cut -d, -f2)

    [ "$complete" -gt 0 ]
    [ "$incomplete" -gt 0 ]
}

@test "mock PRD has feature with dependencies" {
    result=$(python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
has_deps = any(len(f['depends_on']) > 0 for f in data['features'])
print('yes' if has_deps else 'no')
")
    [ "$result" = "yes" ]
}

@test "mock PRD has blocked feature" {
    result=$(python3 -c "
import json
data = json.load(open('$BATS_TEST_DIRNAME/fixtures/mock-prd.json'))
has_blocked = any(f.get('blocked_reason') for f in data['features'])
print('yes' if has_blocked else 'no')
")
    [ "$result" = "yes" ]
}
