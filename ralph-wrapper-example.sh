#!/bin/bash
# Ralph Wrapper Script Example
# Copy this file to your project as 'ralph-local.sh' and adjust RALPH_DIR

# Path to your Ralph toolkit directory
RALPH_DIR="$HOME/code/ralph"

# You can also adjust paths here if needed:
# RALPH_DIR="/path/to/your/ralph"

# Run Ralph with the agent prompt from the toolkit
AGENT_PROMPT_FILE="$RALPH_DIR/AGENT_PROMPT.md" \
  "$RALPH_DIR/ralph.sh" "$@"
