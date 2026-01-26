#!/usr/bin/env bats

# Tests for Feature 007: Error handling and logging improvements

@test "ralph.sh has LOG_LEVEL configuration" {
  grep -q "LOG_LEVEL=" ralph.sh
}

@test "LOG_LEVEL defaults to INFO" {
  grep -q 'LOG_LEVEL="${LOG_LEVEL:-INFO}"' ralph.sh
}

@test "ralph.sh has LOG_FILE configuration" {
  grep -q "LOG_FILE=" ralph.sh
}

@test "ralph.sh has log_debug function" {
  grep -q "^log_debug()" ralph.sh
}

@test "ralph.sh has should_log function" {
  grep -q "^should_log()" ralph.sh
}

@test "ralph.sh has write_to_log_file function" {
  grep -q "^write_to_log_file()" ralph.sh
}

@test "ralph.sh has check_tool function" {
  grep -q "^check_tool()" ralph.sh
}

@test "ralph.sh has check_required_tools function" {
  grep -q "^check_required_tools()" ralph.sh
}

@test "ralph.sh has run_doctor function" {
  grep -q "^run_doctor()" ralph.sh
}

@test "check_prerequisites calls check_required_tools" {
  grep -A 5 "^check_prerequisites()" ralph.sh | grep -q "check_required_tools"
}

@test "--doctor flag is documented in help" {
  ./ralph.sh --help | grep -q "\-\-doctor"
}

@test "--verbose flag is documented in help" {
  ./ralph.sh --help | grep -q "\-\-verbose"
}

@test "--quiet flag is documented in help" {
  ./ralph.sh --help | grep -q "\-\-quiet"
}

@test "LOG_LEVEL is documented in help" {
  ./ralph.sh --help | grep -q "LOG_LEVEL"
}

@test "LOG_FILE is documented in help" {
  ./ralph.sh --help | grep -q "LOG_FILE"
}

@test "--doctor command executes successfully" {
  run ./ralph.sh --doctor
  [ "$status" -eq 0 ]
}

@test "--doctor output includes health check header" {
  ./ralph.sh --doctor | grep -q "Health Check"
}

@test "--doctor checks required tools" {
  ./ralph.sh --doctor | grep -q "Checking required tools"
}

@test "--doctor checks git repository" {
  ./ralph.sh --doctor | grep -q "Checking git repository"
}

@test "--doctor checks .ralph directory" {
  ./ralph.sh --doctor | grep -q "Checking .ralph directory"
}

@test "--doctor checks agent prompt" {
  ./ralph.sh --doctor | grep -q "Checking agent prompt"
}

@test "--doctor checks configuration" {
  ./ralph.sh --doctor | grep -q "Checking configuration"
}

@test "--doctor checks Sanity configuration" {
  ./ralph.sh --doctor | grep -q "Checking Sanity configuration"
}

@test "--doctor checks quality gates" {
  ./ralph.sh --doctor | grep -q "Checking quality gates"
}

@test "--doctor shows completion status" {
  ./ralph.sh --doctor | grep -qE "(All checks passed|Some checks failed)"
}

@test "TROUBLESHOOTING.md exists" {
  [ -f "TROUBLESHOOTING.md" ]
}

@test "TROUBLESHOOTING.md mentions --doctor" {
  grep -q "\-\-doctor" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md has quick health check section" {
  grep -q "Quick Health Check" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md has common issues section" {
  grep -q "Common Issues and Solutions" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md documents missing tools" {
  grep -q "Missing Required Tools" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md documents protected branch error" {
  grep -q "Protected Branch Error" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md documents verbose logging" {
  grep -q "Verbose Logging" TROUBLESHOOTING.md
}

@test "TROUBLESHOOTING.md documents persistent logging" {
  grep -q "Persistent Logging" TROUBLESHOOTING.md
}
