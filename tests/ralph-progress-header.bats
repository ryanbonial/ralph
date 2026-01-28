#!/usr/bin/env bats

# Tests for progress header display (Feature 024)

@test "ralph.sh has SHOW_PROGRESS_HEADER configuration" {
    grep -q "SHOW_PROGRESS_HEADER=" ralph.sh
}

@test "SHOW_PROGRESS_HEADER default is true" {
    grep -q 'SHOW_PROGRESS_HEADER="${SHOW_PROGRESS_HEADER:-true}"' ralph.sh
}

@test "ralph.sh has calculate_prd_stats function" {
    grep -q "calculate_prd_stats()" ralph.sh
}

@test "ralph.sh has get_current_feature_info function" {
    grep -q "get_current_feature_info()" ralph.sh
}

@test "ralph.sh has display_progress_header function" {
    grep -q "display_progress_header()" ralph.sh
}

@test "calculate_prd_stats uses Python to parse JSON" {
    grep -A5 "calculate_prd_stats()" ralph.sh | grep -q "python3"
}

@test "calculate_prd_stats counts total features" {
    grep -A20 "calculate_prd_stats()" ralph.sh | grep -q "total = len(features)"
}

@test "calculate_prd_stats counts completed features" {
    grep -A20 "calculate_prd_stats()" ralph.sh | grep -q "completed = sum.*passes.*True"
}

@test "calculate_prd_stats counts blocked features" {
    grep -A20 "calculate_prd_stats()" ralph.sh | grep -q "blocked = sum.*blocked_reason"
}

@test "calculate_prd_stats returns CSV format" {
    grep -A30 "calculate_prd_stats()" ralph.sh | grep -q "total,completed,blocked,remaining"
}

@test "get_current_feature_info finds next incomplete feature" {
    grep -A20 "get_current_feature_info()" ralph.sh | grep -q "if feature.get.*passes.*True"
}

@test "get_current_feature_info checks dependencies" {
    grep -A30 "get_current_feature_info()" ralph.sh | grep -q "depends_on"
}

@test "get_current_feature_info returns feature ID and type" {
    grep -A40 "get_current_feature_info()" ralph.sh | grep -q "feature_id.*feature_type.*description"
}

@test "get_current_feature_info truncates long descriptions" {
    grep -A35 "get_current_feature_info()" ralph.sh | grep -q "if len(description) > 70"
}

@test "display_progress_header respects SHOW_PROGRESS_HEADER config" {
    grep -A12 "display_progress_header()" ralph.sh | grep -q 'if \[ "$SHOW_PROGRESS_HEADER" != "true" \]'
}

@test "display_progress_header respects LOG_LEVEL" {
    grep -A15 "display_progress_header()" ralph.sh | grep -q 'if \[ "$LOG_LEVEL" = "ERROR" \]'
}

@test "display_progress_header calls get_prd_data" {
    grep -A20 "display_progress_header()" ralph.sh | grep -q "get_prd_data"
}

@test "display_progress_header calls calculate_prd_stats" {
    grep -A25 "display_progress_header()" ralph.sh | grep -q "calculate_prd_stats"
}

@test "display_progress_header accepts feature parameters" {
    # Function should accept feature_id, feature_type, description as parameters
    grep -A10 "display_progress_header()" ralph.sh | grep -q 'local feature_id="\$1"'
}

@test "display_progress_header calculates percentage" {
    grep -A35 "display_progress_header()" ralph.sh | grep -q "percentage"
}

@test "display_progress_header shows current feature with emoji" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q "🎯 Current:"
}

@test "display_progress_header shows progress stats with emoji" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q "📊 Progress:"
}

@test "display_progress_header uses color coding for completed" {
    grep -A60 "display_progress_header()" ralph.sh | grep -q "GREEN.*completed"
}

@test "display_progress_header uses color coding for blocked" {
    grep -A65 "display_progress_header()" ralph.sh | grep -q "RED.*blocked"
}

@test "display_progress_header uses color coding for remaining" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q "YELLOW.*remaining"
}

@test "display_progress_header shows separator lines" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q "═══════════════════"
}

@test "check_prerequisites calls display_progress_header" {
    # Header is now called in check_prerequisites after feature selection (Feature 028)
    awk '/^check_prerequisites\(\)/,/^}$/' ralph.sh | grep -q "display_progress_header"
}

@test "display_progress_header is called in check_prerequisites after feature selection" {
    # Extract check_prerequisites and verify display_progress_header comes after get_next_feature_from_prd
    awk '/^check_prerequisites\(\)/,/^}$/' ralph.sh | grep "get_next_feature_from_prd" -A30 | grep -q "display_progress_header"
}

@test "display_progress_header handles 'none' when all complete" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q 'if \[ "$feature_id" = "none" \]'
}

@test "display_progress_header handles 'error' case" {
    grep -A70 "display_progress_header()" ralph.sh | grep -q 'if \[ "$feature_id" = "error" \]'
}

@test "Feature 024 configuration is documented in help text" {
    # SHOW_PROGRESS_HEADER should be mentioned in documentation or comments
    grep -q "Progress Header" ralph.sh
}

# ==========================================
# Tests for Feature 026: Static header fix
# ==========================================

@test "display_progress_header uses tput to save cursor position" {
    # Header should save cursor position before displaying
    grep -A80 "display_progress_header()" ralph.sh | grep -q "tput sc"
}

@test "display_progress_header uses tput to restore cursor position" {
    # Header should restore cursor position after displaying
    grep -A80 "display_progress_header()" ralph.sh | grep -q "tput rc"
}

@test "display_progress_header uses tput cup to position at top" {
    # Header should position cursor at top of screen (line 0)
    grep -A80 "display_progress_header()" ralph.sh | grep -q "tput cup 0 0"
}

@test "display_progress_header clears the header area before redisplay" {
    # Header should clear previous header lines to avoid artifacts
    grep -A80 "display_progress_header()" ralph.sh | grep -q "tput el"
}

@test "header implementation includes comment about static display" {
    # Code should have a comment explaining the static header technique
    grep -A80 "display_progress_header()" ralph.sh | grep -iq "static\|persist\|remain"
}
# ==========================================
# Tests for Feature 028: Header shows correct selected feature
# ==========================================

@test "header uses get_next_feature_from_prd for feature selection" {
    # Header should rely on get_next_feature_from_prd (which sorts by priority) instead of its own logic
    # check_prerequisites should call get_next_feature_from_prd and pass results to header
    awk '/^check_prerequisites\(\)/,/^}$/' ralph.sh | grep -q "get_next_feature_from_prd"
}

@test "display_progress_header is called AFTER feature selection, not before" {
    # Header should be displayed after we know which feature will be worked on
    # Check that display_progress_header is NOT called before check_prerequisites in main()
    ! awk '/^main\(\)/,/^}/' ralph.sh | grep -B5 "check_prerequisites" | grep -q "display_progress_header"
}

@test "display_progress_header accepts feature parameters instead of parsing PRD" {
    # Header should accept explicit feature_id, feature_type, description parameters
    # This ensures it displays the SELECTED feature, not its own guess
    grep -A5 "^display_progress_header()" ralph.sh | grep -q "local feature_id=\$1\|feature_id=\"\$1\""
}

@test "check_prerequisites passes selected feature info to header" {
    # After feature selection in check_prerequisites, it should call display_progress_header with feature info
    grep -A150 "^check_prerequisites()" ralph.sh | grep "get_next_feature_from_prd" -A30 | grep -q "display_progress_header.*\$"
}

@test "header no longer calls get_current_feature_info internally" {
    # If header accepts parameters, it shouldn't need to call get_current_feature_info
    # It should use the passed parameters instead
    ! grep -A80 "^display_progress_header()" ralph.sh | grep -v "^#" | grep -q "get_current_feature_info"
}
