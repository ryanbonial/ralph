#!/usr/bin/env bats

# Tests for Feature 011: Optimize test output to show only failing tests

@test "ralph.sh has TEST_OUTPUT_MODE configuration" {
    grep -q "TEST_OUTPUT_MODE=" ralph.sh
}

@test "TEST_OUTPUT_MODE default is 'failures'" {
    grep -q 'TEST_OUTPUT_MODE="${TEST_OUTPUT_MODE:-failures}"' ralph.sh
}

@test "ralph.sh has parse_test_output function" {
    grep -q "parse_test_output()" ralph.sh
}

@test "ralph.sh has extract_failing_tests function" {
    grep -q "extract_failing_tests()" ralph.sh
}

@test "ralph.sh has display_test_results function" {
    grep -q "display_test_results()" ralph.sh
}

@test "parse_test_output handles Bats/TAP format" {
    # Verify function handles TAP format with "1..N" pattern
    grep -A 25 "parse_test_output()" ralph.sh | grep -q "Bats/TAP format"
}

@test "parse_test_output handles Jest format" {
    grep -A 20 "parse_test_output()" ralph.sh | grep -q "Tests:"
}

@test "parse_test_output handles Vitest format" {
    grep -A 30 "parse_test_output()" ralph.sh | grep -q "Test Files"
}

@test "parse_test_output handles Mocha format" {
    grep -A 35 "parse_test_output()" ralph.sh | grep -q "passing\|failing"
}

@test "extract_failing_tests handles Bats/TAP format" {
    grep -A 10 "extract_failing_tests()" ralph.sh | grep -q "not ok"
}

@test "extract_failing_tests handles Jest format" {
    grep -A 15 "extract_failing_tests()" ralph.sh | grep -q "FAIL"
}

@test "display_test_results has 'full' mode" {
    grep -A 30 "display_test_results()" ralph.sh | grep -q '"full"'
}

@test "display_test_results has 'summary' mode" {
    grep -A 40 "display_test_results()" ralph.sh | grep -q '"summary"'
}

@test "display_test_results has 'failures' mode" {
    grep -A 50 "display_test_results()" ralph.sh | grep -q '"failures"'
}

@test "Gate 4 uses display_test_results for passed tests" {
    grep -A 150 "# Gate 4: Test Suite" ralph.sh | grep -q 'display_test_results.*"true"'
}

@test "Gate 4 uses display_test_results for failed tests" {
    grep -A 150 "# Gate 4: Test Suite" ralph.sh | grep -q 'display_test_results.*"false"'
}

@test "Gate 4 captures test output to file without tee" {
    # Verify we capture to file
    grep -A 150 "# Gate 4: Test Suite" ralph.sh | grep -q "/tmp/ralph_test.log"
    # Verify we don't use tee (which would display all output)
    ! grep -A 150 "# Gate 4: Test Suite" ralph.sh | grep -q "npm test.*tee"
}

@test "display_test_results shows test summary statistics" {
    grep -A 50 "display_test_results()" ralph.sh | grep -q "Test Summary"
}

@test "display_test_results shows passed count" {
    grep -A 55 "display_test_results()" ralph.sh | grep -q "Passed:"
}

@test "display_test_results shows failed count" {
    grep -A 60 "display_test_results()" ralph.sh | grep -q "Failed:"
}

@test "parse_test_output function parses total from TAP format" {
    # Verify the function logic includes extracting total from "1..X" format
    grep -A 25 "parse_test_output()" ralph.sh | grep -q "sed 's/1"
}

@test "parse_test_output function counts ok/not ok lines" {
    # Verify the function counts passed and failed tests
    grep -A 20 "parse_test_output()" ralph.sh | grep -q 'grep -c "^ok "'
    grep -A 20 "parse_test_output()" ralph.sh | grep -q 'grep -c "^not ok "'
}

@test "extract_failing_tests extracts not ok lines with context" {
    # Verify function extracts failing test details with -A flag for context
    grep -A 15 "extract_failing_tests()" ralph.sh | grep -q 'grep -A 5 "^not ok "'
}

@test "TEST_OUTPUT_MODE configuration is documented" {
    grep -q "Test Output Mode Configuration" ralph.sh
}

@test "TEST_OUTPUT_MODE has three valid options" {
    # Verify all three modes are handled in display_test_results
    grep -A 70 "display_test_results()" ralph.sh | grep -q '"full"'
    grep -A 70 "display_test_results()" ralph.sh | grep -q '"summary"'
    grep -A 70 "display_test_results()" ralph.sh | grep -q '"failures"'
}

@test "parse_test_output returns CSV format" {
    # Function should output: total,passed,failed,skipped
    grep -A 60 "parse_test_output()" ralph.sh | grep -q 'echo.*,.*,.*,'
}

@test "display_test_results handles missing output file gracefully" {
    grep -A 10 "display_test_results()" ralph.sh | grep -q "if \[ ! -f"
}

@test "parse_test_output handles missing output file gracefully" {
    grep -A 10 "parse_test_output()" ralph.sh | grep -q "if \[ ! -f"
}

@test "extract_failing_tests handles missing output file gracefully" {
    grep -A 10 "extract_failing_tests()" ralph.sh | grep -q "if \[ ! -f"
}

@test "display_test_results shows emoji indicators" {
    grep -A 70 "display_test_results()" ralph.sh | grep -q "✅"
    grep -A 70 "display_test_results()" ralph.sh | grep -q "❌"
}
