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
    grep -A5 "display_progress_header()" ralph.sh | grep -q 'if \[ "$SHOW_PROGRESS_HEADER" != "true" \]'
}

@test "display_progress_header respects LOG_LEVEL" {
    grep -A10 "display_progress_header()" ralph.sh | grep -q 'if \[ "$LOG_LEVEL" = "ERROR" \]'
}

@test "display_progress_header calls get_prd_data" {
    grep -A15 "display_progress_header()" ralph.sh | grep -q "get_prd_data"
}

@test "display_progress_header calls calculate_prd_stats" {
    grep -A25 "display_progress_header()" ralph.sh | grep -q "calculate_prd_stats"
}

@test "display_progress_header calls get_current_feature_info" {
    grep -A30 "display_progress_header()" ralph.sh | grep -q "get_current_feature_info"
}

@test "display_progress_header calculates percentage" {
    grep -A35 "display_progress_header()" ralph.sh | grep -q "percentage"
}

@test "display_progress_header shows current feature with emoji" {
    grep -A50 "display_progress_header()" ralph.sh | grep -q "🎯 Current:"
}

@test "display_progress_header shows progress stats with emoji" {
    grep -A55 "display_progress_header()" ralph.sh | grep -q "📊 Progress:"
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
    grep -A48 "display_progress_header()" ralph.sh | grep -q "═══════════════════"
}

@test "main function calls display_progress_header" {
    awk '/^main\(\)/,/^}/' ralph.sh | grep -q "display_progress_header"
}

@test "display_progress_header is called before check_prerequisites" {
    # Extract main function and verify order
    awk '/^main\(\)/,/^}/' ralph.sh | grep -B5 "check_prerequisites" | grep -q "display_progress_header"
}

@test "display_progress_header handles 'none' when all complete" {
    grep -A52 "display_progress_header()" ralph.sh | grep -q 'if \[ "$feature_id" = "none" \]'
}

@test "display_progress_header handles 'error' case" {
    grep -A54 "display_progress_header()" ralph.sh | grep -q 'if \[ "$feature_id" = "error" \]'
}

@test "Feature 024 configuration is documented in help text" {
    # SHOW_PROGRESS_HEADER should be mentioned in documentation or comments
    grep -q "Progress Header" ralph.sh
}
