#!/bin/bash

# Ralph Wiggum Technique - Continuous Agent Loop
# This script runs an AI coding agent in a loop until all features are complete

set -e

# Configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-100}
SLEEP_BETWEEN_ITERATIONS=${SLEEP_BETWEEN_ITERATIONS:-5}
AGENT_PROMPT_FILE="${AGENT_PROMPT_FILE:-AGENT_PROMPT.md}"
PRD_FILE="${PRD_FILE:-.ralph/prd.json}"
PROGRESS_FILE="${PROGRESS_FILE:-.ralph/progress.txt}"

# Git Safety Configuration
# Protect important branches from direct commits
PROTECTED_BRANCHES="${PROTECTED_BRANCHES:-main,master}"
# Allow git push operations (default: false for safety)
ALLOW_GIT_PUSH="${ALLOW_GIT_PUSH:-false}"
# Auto-create feature branches when on protected branch (default: true)
AUTO_CREATE_BRANCH="${AUTO_CREATE_BRANCH:-true}"

# Run Mode Configuration
# Set how the script executes iterations:
# Options:
#   "once"       - Human-in-the-loop: Run one iteration, then stop for review (default)
#   "continuous" - AFK mode: Run until all features complete or max iterations reached
RUN_MODE="${RUN_MODE:-once}"

# AI Agent Configuration
# Set your preferred AI agent command here
# Options:
#   "manual"  - Prompts you to run the agent manually (default for compatibility)
#   "claude"  - Uses Claude CLI (requires: npm install -g @anthropic-ai/claude-cli)
#   "cursor"  - Uses Cursor CLI (if available)
#   "custom"  - Set AI_AGENT_CUSTOM_CMD below for your own command
AI_AGENT_MODE="${AI_AGENT_MODE:-claude}"

# For custom commands, set this variable:
# Example: AI_AGENT_CUSTOM_CMD="your-ai-tool --prompt-file"
AI_AGENT_CUSTOM_CMD="${AI_AGENT_CUSTOM_CMD:-}"

# Git Safety Configuration
# Prevent commits to these branches (comma-separated)
PROTECTED_BRANCHES="${PROTECTED_BRANCHES:-main,master}"

# Allow git push to remote (default: false for safety)
ALLOW_GIT_PUSH="${ALLOW_GIT_PUSH:-false}"

# Error Recovery Configuration
# Automatically rollback git commit if tests fail after implementation
ROLLBACK_ON_FAILURE="${ROLLBACK_ON_FAILURE:-true}"

# Run verification tests before accepting a feature as complete
VERIFY_BEFORE_COMPLETE="${VERIFY_BEFORE_COMPLETE:-true}"

# Code Quality Configuration
# Automatically fix prettier formatting issues before verification
AUTOFIX_PRETTIER="${AUTOFIX_PRETTIER:-true}"

# Test Coverage Configuration (Feature 021)
# Require test files for feature and bug types (default: true)
# When true, features of type 'feature' or 'bug' cannot be marked complete without tests
TEST_REQUIRED_FOR_FEATURES="${TEST_REQUIRED_FOR_FEATURES:-true}"

# Test Output Mode Configuration (Feature 011)
# Controls how much test output is shown to conserve tokens
# Options: "full" (all output), "failures" (only failing tests), "summary" (stats only)
# Default: "failures" (optimal balance of information and token usage)
TEST_OUTPUT_MODE="${TEST_OUTPUT_MODE:-failures}"

# Sanity CMS Configuration (Feature 013)
# Configure Sanity project for PRD storage (used in Feature 014)
SANITY_PROJECT_ID="${SANITY_PROJECT_ID:-}"
SANITY_DATASET="${SANITY_DATASET:-production}"
SANITY_TOKEN="${SANITY_TOKEN:-}"
# PRD storage mode: "file" (default) or "sanity" (requires Feature 014)
PRD_STORAGE="${PRD_STORAGE:-file}"

# Logging Configuration (Feature 007)
# Log level: DEBUG, INFO, WARN, ERROR (default: INFO)
# DEBUG: Show all messages including debug info
# INFO: Show informational messages, warnings, and errors (default)
# WARN: Show only warnings and errors
# ERROR: Show only errors
LOG_LEVEL="${LOG_LEVEL:-INFO}"
# Optional log file for persistent logging (default: none, logs to console only)
# Example: LOG_FILE=".ralph/ralph.log"
LOG_FILE="${LOG_FILE:-}"

# Progress Footer Configuration (Feature 024)
# Show progress footer at the start of each iteration (default: true)
# Footer displays current task and overall progress: "Progress: x/y (z%) complete"
SHOW_PROGRESS_FOOTER="${SHOW_PROGRESS_FOOTER:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Internal function to determine if message should be logged based on level
should_log() {
    local msg_level="$1"

    # Convert levels to numeric values for comparison
    local level_value=0
    case "$LOG_LEVEL" in
        DEBUG) level_value=0 ;;
        INFO)  level_value=1 ;;
        WARN)  level_value=2 ;;
        ERROR) level_value=3 ;;
        *)     level_value=1 ;; # Default to INFO
    esac

    local msg_value=0
    case "$msg_level" in
        DEBUG) msg_value=0 ;;
        INFO)  msg_value=1 ;;
        WARN)  msg_value=2 ;;
        ERROR) msg_value=3 ;;
    esac

    # Log if message level >= configured log level
    [ $msg_value -ge $level_value ]
}

# Internal function to write to log file if configured
write_to_log_file() {
    local level="$1"
    local message="$2"

    if [ -n "$LOG_FILE" ]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Enhanced logging functions with level filtering and file output
log_debug() {
    if should_log "DEBUG"; then
        echo -e "${GRAY}[DEBUG]${NC} $1"
    fi
    write_to_log_file "DEBUG" "$1"
}

log_info() {
    if should_log "INFO"; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
    write_to_log_file "INFO" "$1"
}

log_success() {
    if should_log "INFO"; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
    write_to_log_file "SUCCESS" "$1"
}

log_warning() {
    if should_log "WARN"; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
    write_to_log_file "WARNING" "$1"
}

log_error() {
    if should_log "ERROR"; then
        echo -e "${RED}[ERROR]${NC} $1"
    fi
    write_to_log_file "ERROR" "$1"
}

# ==========================================
# Tool Availability Checking (Feature 007)
# ==========================================

# Check if a command/tool is available
check_tool() {
    local tool="$1"
    local install_hint="$2"

    if command -v "$tool" >/dev/null 2>&1; then
        log_debug "✓ $tool is installed"
        return 0
    else
        log_error "✗ $tool is not installed or not in PATH"
        if [ -n "$install_hint" ]; then
            log_info "  Install with: $install_hint"
        fi
        return 1
    fi
}

# Verify all required tools are available
check_required_tools() {
    log_debug "Checking for required tools..."

    local all_tools_available=true

    # Check git
    if ! check_tool "git" "brew install git (macOS) or apt-get install git (Linux)"; then
        all_tools_available=false
    fi

    # Check python3
    if ! check_tool "python3" "brew install python3 (macOS) or apt-get install python3 (Linux)"; then
        all_tools_available=false
    fi

    # Check curl
    if ! check_tool "curl" "brew install curl (macOS) or apt-get install curl (Linux)"; then
        all_tools_available=false
    fi

    # Check optional tools (don't fail if missing, just warn)
    if ! command -v "node" >/dev/null 2>&1; then
        log_debug "○ node is not installed (optional for quality gates)"
    fi

    if ! command -v "npm" >/dev/null 2>&1; then
        log_debug "○ npm is not installed (optional for quality gates)"
    fi

    if ! command -v "jq" >/dev/null 2>&1; then
        log_debug "○ jq is not installed (optional, Python is used as fallback)"
    fi

    if [ "$all_tools_available" = false ]; then
        log_error "Some required tools are missing. Please install them and try again."
        return 1
    fi

    log_debug "All required tools are available"
    return 0
}

# ==========================================
# Sanity CMS Integration Functions (Feature 014)
# ==========================================

# Validate Sanity configuration
validate_sanity_config() {
    if [ -z "$SANITY_PROJECT_ID" ]; then
        log_error "SANITY_PROJECT_ID not set. Required for PRD_STORAGE=sanity"
        log_info "Set environment variable: export SANITY_PROJECT_ID=your-project-id"
        return 1
    fi

    if [ -z "$SANITY_DATASET" ]; then
        log_error "SANITY_DATASET not set. Required for PRD_STORAGE=sanity"
        log_info "Set environment variable: export SANITY_DATASET=production"
        return 1
    fi

    if [ -z "$SANITY_TOKEN" ]; then
        log_error "SANITY_TOKEN not set. Required for PRD_STORAGE=sanity"
        log_info "Create a token at: https://sanity.io/manage/project/$SANITY_PROJECT_ID/api"
        log_info "Then set: export SANITY_TOKEN=your-token"
        return 1
    fi

    return 0
}

# Fetch PRD from Sanity CMS
fetch_prd_from_sanity() {
    local api_url="https://${SANITY_PROJECT_ID}.api.sanity.io/v2021-10-21/data/query/${SANITY_DATASET}"

    # GROQ query to fetch ralphProject document
    local query='*[_type == "ralphProject"][0]'

    log_info "Fetching PRD from Sanity: $SANITY_PROJECT_ID/$SANITY_DATASET"

    local response=$(curl -s -f \
        --connect-timeout 10 \
        --max-time 30 \
        -H "Authorization: Bearer $SANITY_TOKEN" \
        --get \
        --data-urlencode "query=$query" \
        "$api_url" 2>&1)

    local curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        log_error "Failed to fetch PRD from Sanity (curl exit code: $curl_exit)"
        log_error "Response: $response"
        log_info "Check your SANITY_PROJECT_ID, SANITY_DATASET, and SANITY_TOKEN"
        return 1
    fi

    # Extract result from response
    local prd_doc=$(echo "$response" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    result = data.get('result')
    if result:
        print(json.dumps(result))
    else:
        sys.stderr.write('No result found in Sanity response\n')
        sys.exit(1)
except Exception as e:
    sys.stderr.write(f'Error parsing Sanity response: {e}\n')
    sys.exit(1)
" 2>&1)

    local py_exit=$?

    if [ $py_exit -ne 0 ]; then
        log_error "Failed to parse Sanity response"
        log_error "Error: $prd_doc"
        log_info "Ensure a ralphProject document exists in your Sanity dataset"
        return 1
    fi

    if [ -z "$prd_doc" ] || [ "$prd_doc" = "null" ]; then
        log_error "No ralphProject document found in Sanity"
        log_info "Use the migration script to import your PRD: node .ralph/sanity/migrate.js"
        return 1
    fi

    log_success "PRD fetched from Sanity successfully"
    echo "$prd_doc"
    return 0
}

# Update feature status in Sanity CMS
update_prd_feature_in_sanity() {
    local feature_id="$1"
    local passes="$2"
    local iterations_taken="$3"
    local blocked_reason="$4"

    if [ -z "$feature_id" ]; then
        log_error "Feature ID required for update_prd_feature_in_sanity"
        return 1
    fi

    local api_url="https://${SANITY_PROJECT_ID}.api.sanity.io/v2021-10-21/data/mutate/${SANITY_DATASET}"

    log_info "Updating feature $feature_id in Sanity..."

    # First, fetch the document to get its _id
    local doc_query='*[_type == "ralphProject"][0]{_id, features}'
    local doc_response=$(curl -s -f \
        --connect-timeout 10 \
        --max-time 30 \
        -H "Authorization: Bearer $SANITY_TOKEN" \
        --get \
        --data-urlencode "query=$doc_query" \
        "https://${SANITY_PROJECT_ID}.api.sanity.io/v2021-10-21/data/query/${SANITY_DATASET}")

    if [ $? -ne 0 ]; then
        log_error "Failed to fetch document for update"
        return 1
    fi

    # Build the mutation JSON
    local mutation=$(python3 -c "
import json, sys

doc_response = '''$doc_response'''
feature_id = '$feature_id'
passes = '$passes'
iterations_taken = '$iterations_taken'
blocked_reason = '''$blocked_reason'''

try:
    data = json.loads(doc_response)
    result = data.get('result')

    if not result:
        sys.stderr.write('No document found\n')
        sys.exit(1)

    doc_id = result.get('_id')
    features = result.get('features', [])

    # Find feature index
    feature_idx = None
    for idx, f in enumerate(features):
        if f.get('id') == feature_id:
            feature_idx = idx
            break

    if feature_idx is None:
        sys.stderr.write(f'Feature {feature_id} not found\n')
        sys.exit(1)

    # Build Sanity mutation
    mutations = {
        'mutations': [
            {
                'patch': {
                    'id': doc_id,
                    'set': {
                        f'features[{feature_idx}].passes': passes.lower() == 'true',
                        f'features[{feature_idx}].iterations_taken': int(iterations_taken)
                    }
                }
            }
        ]
    }

    # Add blocked_reason if provided
    if blocked_reason and blocked_reason != 'null':
        mutations['mutations'][0]['patch']['set'][f'features[{feature_idx}].blocked_reason'] = blocked_reason
    else:
        mutations['mutations'][0]['patch']['unset'] = [f'features[{feature_idx}].blocked_reason']

    print(json.dumps(mutations))
except Exception as e:
    sys.stderr.write(f'Error building mutation: {e}\n')
    sys.exit(1)
")

    if [ $? -ne 0 ]; then
        log_error "Failed to build mutation"
        log_error "$mutation"
        return 1
    fi

    # Execute mutation
    local response=$(curl -s -f \
        --connect-timeout 10 \
        --max-time 30 \
        -X POST \
        -H "Authorization: Bearer $SANITY_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$mutation" \
        "$api_url")

    if [ $? -ne 0 ]; then
        log_error "Failed to update feature in Sanity"
        log_error "Response: $response"
        return 1
    fi

    log_success "Feature $feature_id updated in Sanity"
    return 0
}

# Get PRD data (from file or Sanity based on PRD_STORAGE)
get_prd_data() {
    if [ "$PRD_STORAGE" = "sanity" ]; then
        fetch_prd_from_sanity
    else
        if [ ! -f "$PRD_FILE" ]; then
            log_error "PRD file not found: $PRD_FILE"
            return 1
        fi
        cat "$PRD_FILE"
    fi
}

# ==========================================
# End Sanity Integration Functions
# ==========================================

# Check if current branch is protected
is_protected_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

    if [ -z "$current_branch" ]; then
        return 1
    fi

    # Convert comma-separated list to array
    IFS=',' read -ra PROTECTED <<< "$PROTECTED_BRANCHES"

    for protected in "${PROTECTED[@]}"; do
        # Trim whitespace
        protected=$(echo "$protected" | xargs)
        if [ "$current_branch" = "$protected" ]; then
            return 0
        fi
    done

    return 1
}

# Suggest creating a feature branch
suggest_feature_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    echo ""
    log_error "Cannot run Ralph on protected branch: $current_branch"
    echo ""
    log_info "Ralph prevents commits to protected branches for safety."
    log_info "Protected branches: $PROTECTED_BRANCHES"
    echo ""
    log_info "To continue, create a feature branch:"
    echo "  git checkout -b feature/your-feature-name"
    echo ""
    log_info "Or override protection (not recommended):"
    echo "  PROTECTED_BRANCHES=\"\" $0"
    echo ""
}

# Get next feature from PRD (highest priority incomplete feature with met dependencies)
get_next_feature_from_prd() {
    # Get PRD data from file or Sanity
    local prd_data=$(get_prd_data)

    if [ $? -ne 0 ] || [ -z "$prd_data" ]; then
        echo ""
        return 1
    fi

    # Use Python to parse JSON and find next feature
    echo "$prd_data" | python3 -c "
import json
import sys

try:
    prd = json.load(sys.stdin)

    features = prd.get('features', [])

    # Priority order
    priority_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}

    # Filter to incomplete features with met dependencies
    candidates = []
    for feature in features:
        if feature.get('passes', False):
            continue
        if feature.get('blocked_reason'):
            continue

        # Check dependencies
        depends_on = feature.get('depends_on', [])
        deps_met = True
        for dep_id in depends_on:
            dep_feature = next((f for f in features if f.get('id') == dep_id), None)
            if not dep_feature or not dep_feature.get('passes', False):
                deps_met = False
                break

        if deps_met:
            candidates.append(feature)

    if not candidates:
        sys.exit(1)

    # Sort by priority
    candidates.sort(key=lambda f: (
        priority_order.get(f.get('priority', 'low'), 99),
        f.get('id', '')
    ))

    # Output first candidate as JSON
    print(json.dumps(candidates[0]))
except Exception as e:
    sys.stderr.write(f'Error parsing PRD: {e}\n')
    sys.exit(1)
" 2>/dev/null
}

# Generate branch name from feature
generate_branch_name() {
    local feature_json="$1"

    if [ -z "$feature_json" ]; then
        # Fallback to generic name with timestamp
        echo "feature/ralph-$(date +%Y%m%d-%H%M%S)"
        return
    fi

    # Parse feature JSON
    local feature_id=$(echo "$feature_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id', ''))")
    local feature_type=$(echo "$feature_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('type', 'feature'))")
    local feature_desc=$(echo "$feature_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('description', ''))")

    # Determine branch prefix based on type
    local prefix="feature"
    case "$feature_type" in
        bug) prefix="bugfix" ;;
        refactor) prefix="refactor" ;;
        test) prefix="test" ;;
        feature|*) prefix="feature" ;;
    esac

    # Create slug from description (first few words, lowercase, dashes)
    local slug=$(echo "$feature_desc" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr -s ' ' | cut -d' ' -f1-4 | tr ' ' '-')

    # Construct branch name
    if [ -n "$feature_id" ] && [ -n "$slug" ]; then
        echo "${prefix}/${feature_id}-${slug}"
    elif [ -n "$feature_id" ]; then
        echo "${prefix}/${feature_id}"
    else
        echo "${prefix}/ralph-$(date +%Y%m%d-%H%M%S)"
    fi
}

# Auto-create and checkout feature branch
auto_create_feature_branch() {
    local branch_name="$1"

    if [ -z "$branch_name" ]; then
        log_error "No branch name provided"
        return 1
    fi

    log_info "Auto-creating feature branch: $branch_name"

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        log_warning "Branch $branch_name already exists, checking out..."
        git checkout "$branch_name"
    else
        log_info "Creating new branch from current HEAD..."
        git checkout -b "$branch_name"
    fi

    log_success "Now on branch: $branch_name"
    return 0
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check required tools are installed
    if ! check_required_tools; then
        log_error "Missing required tools. Cannot continue."
        exit 1
    fi

    # Check if on protected branch
    if is_protected_branch; then
        if [ "$AUTO_CREATE_BRANCH" = "true" ]; then
            log_warning "Currently on protected branch: $(git rev-parse --abbrev-ref HEAD)"
            echo ""

            # Check if user provided custom branch name
            if [ -n "$CUSTOM_BRANCH_NAME" ]; then
                log_info "Using custom branch name: $CUSTOM_BRANCH_NAME"
                auto_create_feature_branch "$CUSTOM_BRANCH_NAME" || {
                    suggest_feature_branch
                    exit 1
                }
            else
                # Auto-detect next feature and create branch
                log_info "AUTO_CREATE_BRANCH is enabled, inspecting PRD for next feature..."
                local next_feature=$(get_next_feature_from_prd)

                if [ -n "$next_feature" ]; then
                    local feature_desc=$(echo "$next_feature" | python3 -c "import json,sys; print(json.load(sys.stdin).get('description', ''))")
                    log_info "Next feature: $feature_desc"

                    local branch_name=$(generate_branch_name "$next_feature")
                    log_info "Generated branch name: $branch_name"
                    echo ""

                    auto_create_feature_branch "$branch_name" || {
                        suggest_feature_branch
                        exit 1
                    }
                else
                    log_warning "Could not determine next feature from PRD"
                    log_info "Creating generic feature branch..."
                    local fallback_branch="feature/ralph-$(date +%Y%m%d-%H%M%S)"
                    auto_create_feature_branch "$fallback_branch" || {
                        suggest_feature_branch
                        exit 1
                    }
                fi
            fi

            echo ""
            log_success "Branch created successfully! Ready to run Ralph."
            echo ""
        else
            suggest_feature_branch
            exit 1
        fi
    fi

    if [ ! -f "$AGENT_PROMPT_FILE" ]; then
        log_error "Agent prompt file not found: $AGENT_PROMPT_FILE"
        exit 1
    fi

    # Check if .ralph directory exists
    if [ ! -d ".ralph" ]; then
        log_error ".ralph directory not found. Have you initialized the project?"
        log_info "Run the initializer agent first, or create .ralph/ directory manually"
        exit 1
    fi

    # Validate PRD storage configuration
    if [ "$PRD_STORAGE" = "sanity" ]; then
        log_info "PRD_STORAGE=sanity: Using Sanity CMS as source of truth"
        if ! validate_sanity_config; then
            log_error "Sanity configuration invalid"
            exit 1
        fi
        # Test connection by fetching PRD
        if ! get_prd_data > /dev/null; then
            log_error "Failed to fetch PRD from Sanity"
            exit 1
        fi
        log_success "Sanity connection verified"
    else
        # Default file-based storage
        if [ ! -f "$PRD_FILE" ]; then
            log_error "PRD file not found: $PRD_FILE"
            exit 1
        fi
    fi

    if [ ! -f "$PROGRESS_FILE" ]; then
        log_warning "Progress file not found. Creating $PROGRESS_FILE"
        touch "$PROGRESS_FILE"
        echo "=== Ralph Wiggum Progress Log ===" > "$PROGRESS_FILE"
        echo "Started: $(date)" >> "$PROGRESS_FILE"
        echo "" >> "$PROGRESS_FILE"
    fi

    # Check if git repo exists
    if [ ! -d ".git" ]; then
        log_warning "No git repository found. Initializing..."
        git init
        git add .
        git commit -m "Initial commit - Ralph Wiggum setup"
    fi

    log_success "Prerequisites check complete"
}

# Health check command - verify Ralph setup and configuration
run_doctor() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   Ralph Wiggum Health Check (Doctor)  ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    local all_checks_passed=true

    # 1. Check required tools
    log_info "1/7 Checking required tools..."
    if check_required_tools; then
        log_success "✓ All required tools are installed"
    else
        log_error "✗ Some required tools are missing"
        all_checks_passed=false
    fi
    echo ""

    # 2. Check git repository
    log_info "2/7 Checking git repository..."
    if [ -d ".git" ]; then
        log_success "✓ Git repository exists"

        local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "$current_branch" ]; then
            log_info "  Current branch: $current_branch"

            if is_protected_branch; then
                log_warning "  ⚠ You are on a protected branch: $current_branch"
                log_info "  Suggestion: Create a feature branch before running Ralph"
            else
                log_success "  ✓ Branch is safe for commits"
            fi
        fi
    else
        log_error "✗ No git repository found"
        log_info "  Run: git init"
        all_checks_passed=false
    fi
    echo ""

    # 3. Check .ralph directory structure
    log_info "3/7 Checking .ralph directory..."
    if [ -d ".ralph" ]; then
        log_success "✓ .ralph directory exists"

        if [ -f "$PRD_FILE" ]; then
            log_success "  ✓ PRD file exists: $PRD_FILE"

            # Validate PRD JSON structure
            if python3 -c "import json; json.load(open('$PRD_FILE'))" 2>/dev/null; then
                log_success "  ✓ PRD file is valid JSON"

                # Count features
                local total_features=$(python3 -c "import json; prd=json.load(open('$PRD_FILE')); print(len(prd.get('features', [])))" 2>/dev/null)
                local complete_features=$(python3 -c "import json; prd=json.load(open('$PRD_FILE')); print(sum(1 for f in prd.get('features', []) if f.get('passes', False)))" 2>/dev/null)
                log_info "  Features: $complete_features/$total_features complete"
            else
                log_error "  ✗ PRD file is not valid JSON"
                all_checks_passed=false
            fi
        else
            log_error "  ✗ PRD file not found: $PRD_FILE"
            all_checks_passed=false
        fi

        if [ -f "$PROGRESS_FILE" ]; then
            log_success "  ✓ Progress file exists: $PROGRESS_FILE"
        else
            log_warning "  ○ Progress file not found (will be created on first run)"
        fi
    else
        log_error "✗ .ralph directory not found"
        log_info "  Run the Ralph initializer to set up the project"
        all_checks_passed=false
    fi
    echo ""

    # 4. Check agent prompt file
    log_info "4/7 Checking agent prompt..."
    if [ -f "$AGENT_PROMPT_FILE" ]; then
        log_success "✓ Agent prompt file exists: $AGENT_PROMPT_FILE"
    else
        log_error "✗ Agent prompt file not found: $AGENT_PROMPT_FILE"
        all_checks_passed=false
    fi
    echo ""

    # 5. Check configuration
    log_info "5/7 Checking configuration..."
    log_info "  RUN_MODE: $RUN_MODE"
    log_info "  LOG_LEVEL: $LOG_LEVEL"
    log_info "  AUTO_CREATE_BRANCH: $AUTO_CREATE_BRANCH"
    log_info "  PROTECTED_BRANCHES: $PROTECTED_BRANCHES"
    log_info "  ALLOW_GIT_PUSH: $ALLOW_GIT_PUSH"
    log_info "  ROLLBACK_ON_FAILURE: $ROLLBACK_ON_FAILURE"
    log_info "  VERIFY_BEFORE_COMPLETE: $VERIFY_BEFORE_COMPLETE"
    log_info "  TEST_REQUIRED_FOR_FEATURES: $TEST_REQUIRED_FOR_FEATURES"
    log_info "  PRD_STORAGE: $PRD_STORAGE"
    if [ -n "$LOG_FILE" ]; then
        log_info "  LOG_FILE: $LOG_FILE"
    fi
    log_success "✓ Configuration loaded"
    echo ""

    # 6. Check Sanity configuration (if using Sanity)
    log_info "6/7 Checking Sanity configuration..."
    if [ "$PRD_STORAGE" = "sanity" ]; then
        if validate_sanity_config 2>/dev/null; then
            log_success "✓ Sanity configuration is valid"
            log_info "  Project ID: $SANITY_PROJECT_ID"
            log_info "  Dataset: $SANITY_DATASET"

            # Test connection
            if get_prd_data >/dev/null 2>&1; then
                log_success "  ✓ Successfully connected to Sanity"
            else
                log_error "  ✗ Failed to connect to Sanity"
                all_checks_passed=false
            fi
        else
            log_error "✗ Sanity configuration is invalid"
            all_checks_passed=false
        fi
    else
        log_info "  Not using Sanity (PRD_STORAGE=file)"
    fi
    echo ""

    # 7. Check package.json and quality gates (if exists)
    log_info "7/7 Checking quality gates..."
    if [ -f "package.json" ]; then
        log_success "✓ package.json exists"

        if grep -q '"lint"' package.json 2>/dev/null; then
            log_success "  ✓ Linting configured"
        else
            log_info "  ○ No linting script found"
        fi

        if grep -q '"test"' package.json 2>/dev/null; then
            log_success "  ✓ Test script configured"
        else
            log_info "  ○ No test script found"
        fi

        if grep -q '"typecheck"' package.json 2>/dev/null; then
            log_success "  ✓ Type checking configured"
        else
            log_info "  ○ No typecheck script found"
        fi

        if grep -q '"format' package.json 2>/dev/null; then
            log_success "  ✓ Formatting configured"
        else
            log_info "  ○ No formatting script found"
        fi
    else
        log_info "  No package.json found (not a Node.js project)"
    fi
    echo ""

    # Summary
    echo "════════════════════════════════════════"
    if [ "$all_checks_passed" = true ]; then
        log_success "🎉 All checks passed! Ralph is ready to run."
        echo ""
        log_info "You can start Ralph with: ./ralph.sh"
        echo ""
        return 0
    else
        log_error "⚠️  Some checks failed. Please fix the issues above."
        echo ""
        log_info "Run './ralph.sh --help' for more information"
        echo ""
        return 1
    fi
}

# Check if all features are complete
check_completion() {
    local prd_data=$(get_prd_data)

    if [ $? -ne 0 ]; then
        log_error "Failed to get PRD data"
        return 1
    fi

    local incomplete_count=$(echo "$prd_data" | python3 -c "
import json, sys
try:
    prd = json.load(sys.stdin)
    features = prd.get('features', [])
    incomplete = sum(1 for f in features if not f.get('passes', False))
    print(incomplete)
except:
    print('0')
")

    if [ "$incomplete_count" -eq 0 ]; then
        log_success "All features complete!"
        echo "  🎓 \"I'm learnding!\" - Ralph Wiggum"
        echo ""
        return 0
    else
        log_info "Remaining features: $incomplete_count"
        return 1
    fi
}

# Calculate PRD statistics (Feature 024)
# Returns: total,completed,blocked,in_progress
# Also sets CURRENT_FEATURE_DATA global variable with current feature JSON
calculate_prd_stats() {
    local prd_data=$(get_prd_data)

    if [ $? -ne 0 ]; then
        echo "0,0,0,0"
        return 1
    fi

    # Parse statistics using Python
    local stats=$(echo "$prd_data" | python3 -c "
import json, sys
try:
    prd = json.load(sys.stdin)
    features = prd.get('features', [])

    total = len(features)
    completed = sum(1 for f in features if f.get('passes', False))
    blocked = sum(1 for f in features if f.get('blocked_reason'))
    in_progress = total - completed - blocked

    print(f'{total},{completed},{blocked},{in_progress}')
except Exception as e:
    sys.stderr.write(f'Error: {e}\n')
    print('0,0,0,0')
" 2>/dev/null)

    # Get current feature (next feature to work on)
    CURRENT_FEATURE_DATA=$(get_next_feature_from_prd)

    echo "$stats"
}

# Display progress footer showing current task and overall progress (Feature 024)
display_progress_footer() {
    # Skip if footer is disabled
    if [ "$SHOW_PROGRESS_FOOTER" != "true" ]; then
        return 0
    fi

    # Calculate statistics
    local stats=$(calculate_prd_stats)
    IFS=',' read -r total completed blocked in_progress <<< "$stats"

    # Calculate percentage
    local percent=0
    if [ "$total" -gt 0 ]; then
        percent=$((completed * 100 / total))
    fi

    # Prepare current task display
    local current_task_display="None (all complete)"
    if [ -n "$CURRENT_FEATURE_DATA" ] && [ "$CURRENT_FEATURE_DATA" != "null" ]; then
        # Parse current feature data
        local feature_id=$(echo "$CURRENT_FEATURE_DATA" | python3 -c "import json, sys; f=json.load(sys.stdin); print(f.get('id', 'unknown'))" 2>/dev/null)
        local feature_type=$(echo "$CURRENT_FEATURE_DATA" | python3 -c "import json, sys; f=json.load(sys.stdin); print(f.get('type', 'unknown'))" 2>/dev/null)
        local feature_desc=$(echo "$CURRENT_FEATURE_DATA" | python3 -c "import json, sys; f=json.load(sys.stdin); print(f.get('description', 'unknown'))" 2>/dev/null)

        # Truncate description if too long
        if [ ${#feature_desc} -gt 60 ]; then
            feature_desc="${feature_desc:0:57}..."
        fi

        current_task_display="${feature_id} - ${feature_type} - ${feature_desc}"
    fi

    # Display footer with color coding
    echo ""
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    printf "│ ${BLUE}Current Task:${NC} %-60s │\n" "$current_task_display"

    # Build progress text for display
    local progress_display="$completed/$total ($percent%) complete"

    # Calculate text length (without ANSI codes)
    # "Progress: " = 10 chars, progress_display, optional " | X blocked"
    local text_length=$((10 + ${#progress_display}))
    if [ "$blocked" -gt 0 ]; then
        local blocked_text="$blocked blocked"
        text_length=$((text_length + 3 + ${#blocked_text}))  # 3 for " | "
    fi

    # Calculate padding (72 total - 2 for "│ " - 2 for " │" = 68 for content)
    local content_width=68
    local padding=$((content_width - text_length))

    # Display progress line with colors
    printf "│ ${GREEN}Progress:${NC} %s" "$progress_display"
    if [ "$blocked" -gt 0 ]; then
        printf " | ${RED}%d blocked${NC}" "$blocked"
    fi
    printf "%${padding}s │\n" ""

    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo ""
}

# Parse test output to extract test statistics and failures
# Arguments: $1 = output file path
# Outputs: total,passed,failed,skipped
parse_test_output() {
    local output_file="$1"

    if [ ! -f "$output_file" ]; then
        echo "0,0,0,0"
        return 1
    fi

    # Try to detect test framework and parse accordingly
    local total=0 passed=0 failed=0 skipped=0

    # Bats/TAP format: "1..108" and "ok/not ok" lines
    if grep -q "^1\.\.[0-9]" "$output_file"; then
        total=$(grep "^1\.\." "$output_file" | head -1 | sed 's/1\.\.//')
        passed=$(grep -c "^ok " "$output_file" || echo "0")
        failed=$(grep -c "^not ok " "$output_file" || echo "0")
        skipped=$(grep -c "^ok .* # skip" "$output_file" || echo "0")

    # Jest format: "Tests: X failed, Y passed, Z total"
    elif grep -q "Tests:" "$output_file"; then
        failed=$(grep "Tests:" "$output_file" | tail -1 | sed -n 's/.*\([0-9]\+\) failed.*/\1/p' || echo "0")
        passed=$(grep "Tests:" "$output_file" | tail -1 | sed -n 's/.*\([0-9]\+\) passed.*/\1/p' || echo "0")
        skipped=$(grep "Tests:" "$output_file" | tail -1 | sed -n 's/.*\([0-9]\+\) skipped.*/\1/p' || echo "0")
        total=$(grep "Tests:" "$output_file" | tail -1 | sed -n 's/.*\([0-9]\+\) total.*/\1/p' || echo "0")

    # Vitest format: "Test Files X passed (Y)" or "FAIL X tests failed"
    elif grep -qE "(Test Files|PASS|FAIL)" "$output_file"; then
        failed=$(grep -oE "([0-9]+) failed" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        passed=$(grep -oE "([0-9]+) passed" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        skipped=$(grep -oE "([0-9]+) skipped" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        total=$((passed + failed + skipped))

    # Mocha format: "X passing" "Y failing"
    elif grep -qE "[0-9]+ (passing|failing)" "$output_file"; then
        passed=$(grep -oE "[0-9]+ passing" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        failed=$(grep -oE "[0-9]+ failing" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        skipped=$(grep -oE "[0-9]+ pending" "$output_file" | tail -1 | awk '{print $1}' || echo "0")
        total=$((passed + failed + skipped))

    # Fallback: try to count based on common patterns
    else
        # Count lines that look like test results
        passed=$(grep -cE "(✓|✔|PASS|\[32mok)" "$output_file" 2>/dev/null || echo "0")
        failed=$(grep -cE "(✗|✘|FAIL|\[31mnot ok)" "$output_file" 2>/dev/null || echo "0")
        total=$((passed + failed))
    fi

    echo "$total,$passed,$failed,$skipped"
}

# Extract only failing test details from output
# Arguments: $1 = output file path
extract_failing_tests() {
    local output_file="$1"

    if [ ! -f "$output_file" ]; then
        return 1
    fi

    # Bats/TAP format: Extract "not ok" lines and context
    if grep -q "^not ok " "$output_file"; then
        grep -A 5 "^not ok " "$output_file"
        return 0
    fi

    # Jest format: Extract "FAIL" blocks
    if grep -q "FAIL" "$output_file"; then
        # Extract lines from FAIL markers to next blank line
        awk '/FAIL/,/^$/' "$output_file"
        return 0
    fi

    # Vitest format: Extract failure sections
    if grep -q "FAIL" "$output_file"; then
        awk '/FAIL/,/^$/' "$output_file"
        return 0
    fi

    # Mocha format: Extract failing test blocks
    if grep -q "failing" "$output_file"; then
        # Extract from first failure marker onwards
        sed -n '/failing/,$p' "$output_file"
        return 0
    fi

    # Generic fallback: show lines with error indicators
    grep -E "(Error|FAIL|✗|✘|not ok)" "$output_file" || echo "No detailed failure information available"
}

# Display test results based on TEST_OUTPUT_MODE
# Arguments: $1 = output file path, $2 = success/failure status
display_test_results() {
    local output_file="$1"
    local test_passed="$2"

    if [ ! -f "$output_file" ]; then
        log_warning "No test output file found"
        return
    fi

    # Parse test statistics
    local stats=$(parse_test_output "$output_file")
    local total=$(echo "$stats" | cut -d',' -f1)
    local passed=$(echo "$stats" | cut -d',' -f2)
    local failed=$(echo "$stats" | cut -d',' -f3)
    local skipped=$(echo "$stats" | cut -d',' -f4)

    case "$TEST_OUTPUT_MODE" in
        "full")
            # Show everything (original behavior)
            cat "$output_file"
            ;;

        "summary")
            # Show only statistics
            echo ""
            echo "📊 Test Summary:"
            echo "   Total:   $total tests"
            echo "   Passed:  $passed ✅"
            if [ "$failed" -gt 0 ]; then
                echo "   Failed:  $failed ❌"
            fi
            if [ "$skipped" -gt 0 ]; then
                echo "   Skipped: $skipped ⊘"
            fi
            echo ""
            ;;

        "failures"|*)
            # Show summary + only failing tests (default)
            echo ""
            echo "📊 Test Summary:"
            echo "   Total:   $total tests"
            echo "   Passed:  $passed ✅"
            if [ "$failed" -gt 0 ]; then
                echo "   Failed:  $failed ❌"
            fi
            if [ "$skipped" -gt 0 ]; then
                echo "   Skipped: $skipped ⊘"
            fi
            echo ""

            if [ "$test_passed" != "true" ] && [ "$failed" -gt 0 ]; then
                echo "❌ Failing Tests:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                extract_failing_tests "$output_file"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
            fi
            ;;
    esac
}

# Run verification tests
run_verification_tests() {
    log_info "Running code quality gates..."
    echo ""

    local tests_passed=true
    local quality_gate_results=""

    # Gate 1: Code Formatting (Prettier/Black/etc)
    if [ -f "package.json" ]; then
        if grep -q '"format:check"' package.json || grep -q '"prettier"' package.json; then
            log_info "🎨 Quality Gate 1/5: Code Formatting"

            # Auto-fix if enabled
            if [ "$AUTOFIX_PRETTIER" = "true" ]; then
                if grep -q '"format"' package.json; then
                    log_info "Auto-fixing formatting issues..."
                    npm run format 2>&1 | tee /tmp/ralph_format.log || true
                fi
            fi

            # Check formatting
            if grep -q '"format:check"' package.json; then
                if ! npm run format:check 2>&1 | tee /tmp/ralph_format_check.log; then
                    log_error "❌ FAILED: Code formatting issues detected"
                    log_info "Fix with: npm run format"
                    quality_gate_results="${quality_gate_results}\n  ❌ Formatting"
                    tests_passed=false
                else
                    log_success "✅ PASSED: Code formatting"
                    quality_gate_results="${quality_gate_results}\n  ✅ Formatting"
                fi
            elif command -v prettier &> /dev/null; then
                if ! prettier --check . 2>&1 | tee /tmp/ralph_prettier.log; then
                    log_error "❌ FAILED: Prettier formatting issues detected"
                    log_info "Fix with: prettier --write ."
                    quality_gate_results="${quality_gate_results}\n  ❌ Formatting"
                    tests_passed=false
                else
                    log_success "✅ PASSED: Prettier formatting"
                    quality_gate_results="${quality_gate_results}\n  ✅ Formatting"
                fi
            else
                log_info "⊘ SKIPPED: No formatting tool configured"
                quality_gate_results="${quality_gate_results}\n  ⊘ Formatting (not configured)"
            fi
            echo ""
        fi
    fi

    # Gate 2: Linting (MUST PASS - blocking)
    log_info "🔍 Quality Gate 2/5: Linting"
    if [ -f "package.json" ] && grep -q '"lint"' package.json; then
        if ! npm run lint 2>&1 | tee /tmp/ralph_lint.log; then
            log_error "❌ FAILED: Linting errors detected (BLOCKING)"
            log_info "Fix linting issues before marking feature complete"
            quality_gate_results="${quality_gate_results}\n  ❌ Linting"
            tests_passed=false
        else
            log_success "✅ PASSED: Linting"
            quality_gate_results="${quality_gate_results}\n  ✅ Linting"
        fi
    else
        log_info "⊘ SKIPPED: No linting configured"
        quality_gate_results="${quality_gate_results}\n  ⊘ Linting (not configured)"
    fi
    echo ""

    # Gate 3: Type Checking (MUST PASS if configured)
    log_info "🔎 Quality Gate 3/5: Type Checking"
    if [ -f "package.json" ] && grep -q '"typecheck"' package.json; then
        if ! npm run typecheck 2>&1 | tee /tmp/ralph_typecheck.log; then
            log_error "❌ FAILED: Type checking errors detected (BLOCKING)"
            log_info "Fix type errors before marking feature complete"
            quality_gate_results="${quality_gate_results}\n  ❌ Type Checking"
            tests_passed=false
        else
            log_success "✅ PASSED: Type checking"
            quality_gate_results="${quality_gate_results}\n  ✅ Type Checking"
        fi
    elif [ -f "tsconfig.json" ] || [ -f "package.json" ] && grep -q '"typescript"' package.json; then
        if command -v tsc &> /dev/null; then
            if ! tsc --noEmit 2>&1 | tee /tmp/ralph_tsc.log; then
                log_error "❌ FAILED: TypeScript compilation errors (BLOCKING)"
                quality_gate_results="${quality_gate_results}\n  ❌ Type Checking"
                tests_passed=false
            else
                log_success "✅ PASSED: TypeScript"
                quality_gate_results="${quality_gate_results}\n  ✅ Type Checking"
            fi
        else
            log_info "⊘ SKIPPED: TypeScript found but tsc not available"
            quality_gate_results="${quality_gate_results}\n  ⊘ Type Checking (tsc not found)"
        fi
    else
        log_info "⊘ SKIPPED: No type checking configured"
        quality_gate_results="${quality_gate_results}\n  ⊘ Type Checking (not configured)"
    fi
    echo ""

    # Gate 4: Test Suite (MUST PASS if tests exist)
    log_info "🧪 Quality Gate 4/5: Test Suite"
    if [ -f "package.json" ] && grep -q '"test"' package.json; then
        # Capture test output to file (don't display yet)
        local test_exit_code=0
        npm test > /tmp/ralph_test.log 2>&1 || test_exit_code=$?

        # Display results based on TEST_OUTPUT_MODE
        if [ $test_exit_code -ne 0 ]; then
            log_error "❌ FAILED: Test suite failed (BLOCKING)"
            display_test_results "/tmp/ralph_test.log" "false"
            log_info "Fix failing tests before marking feature complete"
            quality_gate_results="${quality_gate_results}\n  ❌ Tests"
            tests_passed=false
        else
            log_success "✅ PASSED: Test suite"
            display_test_results "/tmp/ralph_test.log" "true"
            quality_gate_results="${quality_gate_results}\n  ✅ Tests"
        fi
    else
        log_info "⊘ SKIPPED: No tests configured"
        quality_gate_results="${quality_gate_results}\n  ⊘ Tests (not configured)"
    fi
    echo ""

    # Gate 5: Test Coverage (MUST have tests for feature/bug types)
    log_info "📋 Quality Gate 5/5: Test Coverage"
    if [ "$TEST_REQUIRED_FOR_FEATURES" = "true" ]; then
        # Get the current feature being worked on
        local prd_content=$(get_prd_data)
        local feature_type=$(echo "$prd_content" | python3 -c "
import sys, json
prd = json.load(sys.stdin)
for feature in prd.get('features', []):
    if not feature.get('passes', False):
        blocked = feature.get('blocked_reason')
        if blocked is None or blocked == '':
            depends_on = feature.get('depends_on', [])
            all_deps_met = True
            for dep_id in depends_on:
                dep_complete = any(f.get('id') == dep_id and f.get('passes', False) for f in prd.get('features', []))
                if not dep_complete:
                    all_deps_met = False
                    break
            if all_deps_met:
                print(feature.get('type', 'feature'))
                break
" 2>/dev/null)

        local test_files=$(echo "$prd_content" | python3 -c "
import sys, json
prd = json.load(sys.stdin)
for feature in prd.get('features', []):
    if not feature.get('passes', False):
        blocked = feature.get('blocked_reason')
        if blocked is None or blocked == '':
            depends_on = feature.get('depends_on', [])
            all_deps_met = True
            for dep_id in depends_on:
                dep_complete = any(f.get('id') == dep_id and f.get('passes', False) for f in prd.get('features', []))
                if not dep_complete:
                    all_deps_met = False
                    break
            if all_deps_met:
                # Collect test files from both test_files and acceptance_criteria
                all_tests = set()
                test_files = feature.get('test_files', [])
                for tf in test_files:
                    all_tests.add(tf)

                acceptance = feature.get('acceptance_criteria', {})
                for ut in acceptance.get('unit_tests', []):
                    all_tests.add(ut)
                for et in acceptance.get('e2e_tests', []):
                    all_tests.add(et)

                for test_file in all_tests:
                    print(test_file)
                break
" 2>/dev/null)

        if [ "$feature_type" = "feature" ] || [ "$feature_type" = "bug" ]; then
            if [ -n "$test_files" ]; then
                # Check if specified test files exist
                local missing_files=""
                for test_file in $test_files; do
                    if [ ! -f "$test_file" ]; then
                        missing_files="${missing_files}\n    - $test_file"
                    fi
                done

                if [ -n "$missing_files" ]; then
                    log_error "❌ FAILED: Required test files missing (BLOCKING)"
                    log_info "Feature type '$feature_type' requires tests. Missing files:${missing_files}"
                    log_info "Create these test files before marking feature complete"
                    quality_gate_results="${quality_gate_results}\n  ❌ Test Coverage"
                    tests_passed=false
                else
                    log_success "✅ PASSED: All required test files exist"
                    quality_gate_results="${quality_gate_results}\n  ✅ Test Coverage"

                    # Display manual checks from acceptance_criteria if present
                    local manual_checks=$(echo "$prd_content" | python3 -c "
import sys, json
prd = json.load(sys.stdin)
for feature in prd.get('features', []):
    if not feature.get('passes', False):
        blocked = feature.get('blocked_reason')
        if blocked is None or blocked == '':
            depends_on = feature.get('depends_on', [])
            all_deps_met = True
            for dep_id in depends_on:
                dep_complete = any(f.get('id') == dep_id and f.get('passes', False) for f in prd.get('features', []))
                if not dep_complete:
                    all_deps_met = False
                    break
            if all_deps_met:
                acceptance = feature.get('acceptance_criteria', {})
                manual_checks = acceptance.get('manual_checks', [])
                if manual_checks:
                    for check in manual_checks:
                        print(f'    - {check}')
                break
" 2>/dev/null)
                    if [ -n "$manual_checks" ]; then
                        log_info "📋 Manual acceptance checks to verify:"
                        echo -e "$manual_checks"
                    fi
                fi
            else
                # No test_files specified - check if any test files exist in tests/ directory
                if [ -d "tests" ]; then
                    local test_count=$(find tests -name "*.bats" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*.spec.js" -o -name "*.spec.ts" 2>/dev/null | wc -l)
                    if [ "$test_count" -gt 0 ]; then
                        log_success "✅ PASSED: Test files found (${test_count} test files in tests/)"
                        quality_gate_results="${quality_gate_results}\n  ✅ Test Coverage"
                    else
                        log_warning "⚠️  WARNING: Feature type '$feature_type' should have tests"
                        log_info "Consider adding 'test_files' field to PRD to specify required test files"
                        log_info "Or add test files to tests/ directory"
                        quality_gate_results="${quality_gate_results}\n  ⚠️  Test Coverage (no test_files specified)"
                        # Don't fail, just warn - backward compatible
                    fi
                else
                    log_warning "⚠️  WARNING: Feature type '$feature_type' should have tests"
                    log_info "Consider adding test files or specifying 'test_files' in PRD"
                    quality_gate_results="${quality_gate_results}\n  ⚠️  Test Coverage (no tests/ directory)"
                    # Don't fail, just warn - backward compatible
                fi
            fi
        elif [ "$feature_type" = "refactor" ]; then
            log_success "✅ PASSED: Refactor type - existing tests prove behavior unchanged"
            quality_gate_results="${quality_gate_results}\n  ✅ Test Coverage (refactor)"
        elif [ "$feature_type" = "test" ]; then
            log_success "✅ PASSED: Test type - implementation is the tests"
            quality_gate_results="${quality_gate_results}\n  ✅ Test Coverage (test type)"
        else
            log_info "⊘ SKIPPED: Test coverage check for type '$feature_type'"
            quality_gate_results="${quality_gate_results}\n  ⊘ Test Coverage (type: $feature_type)"
        fi
    else
        log_info "⊘ SKIPPED: TEST_REQUIRED_FOR_FEATURES is disabled"
        quality_gate_results="${quality_gate_results}\n  ⊘ Test Coverage (disabled)"
    fi
    echo ""

    # Summary
    echo "=========================================="
    log_info "Quality Gate Summary:"
    echo -e "$quality_gate_results"
    echo "=========================================="
    echo ""

    if [ "$tests_passed" = true ]; then
        log_success "✅ ALL QUALITY GATES PASSED"
        return 0
    else
        log_error "❌ QUALITY GATES FAILED - Feature cannot be marked complete"
        echo "  💭 \"Me fail English? That's unpossible!\" - Ralph Wiggum"
        log_warning "Fix the issues above and try again"
        return 1
    fi
}

# Rollback the last commit
rollback_last_commit() {
    log_warning "Rolling back last commit... 🧸"
    echo "  💭 \"I bent my Wookiee!\" - Ralph Wiggum"
    echo ""

    local last_commit=$(git log -1 --pretty=%B 2>/dev/null || echo "")
    if [ -n "$last_commit" ]; then
        log_info "Reverting: $last_commit"
        git reset --hard HEAD~1
        log_success "Rollback complete"
    else
        log_warning "No commit to rollback"
    fi
}

# Check for unauthorized git push operations
check_for_git_push() {
    if [ "$ALLOW_GIT_PUSH" != "true" ]; then
        # Check if last git command was a push
        local git_reflog=$(git reflog -1 2>/dev/null || echo "")
        if echo "$git_reflog" | grep -q "push"; then
            log_error "Git push detected but ALLOW_GIT_PUSH is not enabled!"
            log_warning "For safety, Ralph blocks git push by default."
            log_info "To enable pushing:"
            echo "  ALLOW_GIT_PUSH=true $0"
            echo ""
            return 1
        fi
    fi
    return 0
}

# Main loop
run_ralph_loop() {
    if [ "$RUN_MODE" = "once" ]; then
        log_info "Starting Ralph Wiggum (human-in-the-loop mode - single iteration)"
        echo "  🍌 \"Go banana!\" - Ralph Wiggum"
        echo ""
        run_single_iteration 1
    else
        log_info "Starting Ralph Wiggum loop (continuous mode - max $MAX_ITERATIONS iterations)"
        echo "  🍌 \"Go banana!\" - Ralph Wiggum"
        echo ""
        run_continuous_loop
    fi
}

# Run a single iteration (human-in-the-loop)
run_single_iteration() {
    local iteration=${1:-1}

    echo ""
    echo "=========================================="
    log_info "Iteration $iteration (Human-in-the-Loop)"
    echo "=========================================="
    echo ""

    # Display progress footer (Feature 024)
    display_progress_footer

    # Check if already complete
    if check_completion; then
        log_success "Project complete! Exiting."
        exit 0
    fi

    # Run the agent based on configured mode
    execute_agent

    # Check if agent declared completion
    if check_completion; then
        log_success "PROMISE COMPLETE - All features implemented!"
        exit 0
    fi

    # Verify a commit was made
    LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B 2>/dev/null || echo "")
    if [ -n "$LAST_COMMIT_MESSAGE" ]; then
        log_success "Commit detected: $LAST_COMMIT_MESSAGE"

        # Check for unauthorized git push
        check_for_git_push

        # Run verification tests if enabled
        if [ "$VERIFY_BEFORE_COMPLETE" = "true" ]; then
            if ! run_verification_tests; then
                if [ "$ROLLBACK_ON_FAILURE" = "true" ]; then
                    log_error "Verification failed - rolling back changes"
                    rollback_last_commit
                    echo ""
                    log_warning "Feature may need to be reworked or marked as blocked"
                else
                    log_warning "Verification failed but rollback is disabled"
                    log_info "You may want to fix issues before continuing"
                fi
            else
                log_success "Verification passed - changes accepted"
            fi
        fi
    else
        log_warning "No git commit detected in this iteration"
    fi

    echo ""
    echo "=========================================="
    log_success "Iteration Complete"
    echo "=========================================="
    echo ""
    log_info "Review the changes made:"
    echo "  - Check git diff: git diff HEAD~1"
    echo "  - Review PRD: cat $PRD_FILE"
    echo "  - Check progress: tail -20 $PROGRESS_FILE"
    echo ""
    log_info "To continue with the next iteration, run: $0"
    echo ""
}

# Run continuous loop (AFK mode)
run_continuous_loop() {
    for iteration in $(seq 1 $MAX_ITERATIONS); do
        echo ""
        echo "=========================================="
        log_info "Iteration $iteration of $MAX_ITERATIONS (Continuous Mode)"
        echo "=========================================="
        echo ""

        # Display progress footer (Feature 024)
        display_progress_footer

        # Check if already complete
        if check_completion; then
            log_success "Project complete! Exiting."
            exit 0
        fi

        # Run the agent
        execute_agent

        # Check if agent declared completion
        if check_completion; then
            log_success "PROMISE COMPLETE - All features implemented!"
            exit 0
        fi

        # Verify a commit was made
        LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B 2>/dev/null || echo "")
        if [ -n "$LAST_COMMIT_MESSAGE" ]; then
            log_success "Commit detected: $LAST_COMMIT_MESSAGE"

            # Check for unauthorized git push
            check_for_git_push

            # Run verification tests if enabled
            if [ "$VERIFY_BEFORE_COMPLETE" = "true" ]; then
                if ! run_verification_tests; then
                    if [ "$ROLLBACK_ON_FAILURE" = "true" ]; then
                        log_error "Verification failed - rolling back changes"
                        rollback_last_commit
                        log_warning "Continuing to next iteration (feature may be blocked)"
                    else
                        log_warning "Verification failed but rollback is disabled"
                    fi
                else
                    log_success "Verification passed - changes accepted"
                fi
            fi
        else
            log_warning "No git commit detected in this iteration"
        fi

        # Sleep before next iteration (give user time to review)
        if [ $iteration -lt $MAX_ITERATIONS ]; then
            log_info "Waiting $SLEEP_BETWEEN_ITERATIONS seconds before next iteration..."
            sleep $SLEEP_BETWEEN_ITERATIONS
        fi
    done

    echo ""
    log_warning "Reached maximum iterations ($MAX_ITERATIONS) without completing all features"
    check_completion
}

# Execute the AI agent based on configured mode
execute_agent() {
    log_info "Running agent (mode: $AI_AGENT_MODE)..."

    case "$AI_AGENT_MODE" in
        claude)
            log_info "Using Claude CLI..."
            if command -v claude &> /dev/null; then
                cat "$AGENT_PROMPT_FILE" | claude
            elif command -v npx &> /dev/null; then
                log_info "Claude CLI not found globally, trying npx..."
                cat "$AGENT_PROMPT_FILE" | npx -y @anthropic-ai/claude-cli
            else
                log_error "Claude CLI not found. Install with: npm install -g @anthropic-ai/claude-cli"
                log_info "Falling back to manual mode for this iteration..."
                AI_AGENT_MODE="manual"
                execute_agent
            fi
            ;;
        cursor)
            log_info "Using Cursor CLI..."
            if command -v cursor-agent &> /dev/null; then
                cat "$AGENT_PROMPT_FILE" | cursor-agent
            else
                log_error "Cursor CLI not found"
                log_info "Falling back to manual mode for this iteration..."
                AI_AGENT_MODE="manual"
                execute_agent
            fi
            ;;
        custom)
            if [ -n "$AI_AGENT_CUSTOM_CMD" ]; then
                log_info "Using custom command: $AI_AGENT_CUSTOM_CMD"
                cat "$AGENT_PROMPT_FILE" | $AI_AGENT_CUSTOM_CMD
            else
                log_error "AI_AGENT_CUSTOM_CMD not set"
                log_info "Falling back to manual mode for this iteration..."
                AI_AGENT_MODE="manual"
                execute_agent
            fi
            ;;
        manual|*)
            echo ""
            log_warning "MANUAL STEP REQUIRED:"
            echo "1. Open your AI agent (Claude, Cursor, etc.)"
            echo "2. Provide this file: $AGENT_PROMPT_FILE"
            echo "3. Let the agent complete its work"
            echo "4. Check the terminal for git commit"
            echo ""
            read -p "Press Enter when agent has completed this iteration..."
            ;;
    esac
}

# Main execution
main() {
    # Parse command line arguments
    CUSTOM_BRANCH_NAME=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --branch-name)
                CUSTOM_BRANCH_NAME="$2"
                shift 2
                ;;
            --verbose|-v)
                LOG_LEVEL="DEBUG"
                shift
                ;;
            --quiet|-q)
                LOG_LEVEL="ERROR"
                shift
                ;;
            --doctor)
                run_doctor
                exit $?
                ;;
            --help|-h)
                echo "Ralph Wiggum Technique - Autonomous Coding Agent"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --branch-name NAME    Specify custom branch name for auto-creation"
                echo "  --verbose, -v         Enable verbose output (LOG_LEVEL=DEBUG)"
                echo "  --quiet, -q           Minimal output, errors only (LOG_LEVEL=ERROR)"
                echo "  --doctor              Run health check to verify Ralph setup"
                echo "  --help, -h            Show this help message"
                echo ""
                echo "Environment Variables:"
                echo "  RUN_MODE              'once' (default) or 'continuous'"
                echo "  LOG_LEVEL             'DEBUG', 'INFO' (default), 'WARN', 'ERROR'"
                echo "  LOG_FILE              Optional log file path for persistent logging"
                echo "  SHOW_PROGRESS_FOOTER  'true' (default) or 'false'"
                echo "  AUTO_CREATE_BRANCH    'true' (default) or 'false'"
                echo "  PROTECTED_BRANCHES    Comma-separated list (default: 'main,master')"
                echo "  ALLOW_GIT_PUSH        'true' or 'false' (default: false)"
                echo "  PRD_STORAGE           'file' (default) or 'sanity'"
                echo ""
                echo "Examples:"
                echo "  $0                    Run once in human-in-the-loop mode"
                echo "  $0 --doctor           Check Ralph setup and configuration"
                echo "  $0 --verbose          Run with verbose logging"
                echo "  RUN_MODE=continuous $0   Run in continuous mode"
                echo ""
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   Ralph Wiggum Technique - Agent Loop  ║"
    if [ "$RUN_MODE" = "once" ]; then
        echo "║        Human-in-the-Loop Mode          ║"
    else
        echo "║          Continuous AFK Mode           ║"
    fi
    echo "╚════════════════════════════════════════╝"
    echo ""

    check_prerequisites
    run_ralph_loop
}

# Run main function only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
