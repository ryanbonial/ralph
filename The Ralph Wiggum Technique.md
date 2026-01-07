# The Ralph Wiggum Technique

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world." - Geoffrey Huntley

The Ralph Wiggum Technique is a method for autonomous, incremental software development using AI agents in a continuous loop. Based on research from [Anthropic's long-running agent harness](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) and the [Ralph Wiggum loop pattern](https://ghuntley.com/ralph/), this approach enables AI agents to build complex applications systematically across multiple context windows.

## Overview

At its core, Ralph is simple:

```bash
while :; do cat PROMPT.md | claude-code ; done
```

But effective long-running agents require structure to work incrementally across many sessions. This document provides everything you need to implement the Ralph Wiggum Technique.

## Core Components

### 1. Feature List (`.ralph/prd.json`)

A JSON file containing all features to be implemented, each with a test specification and completion status.

### 2. Progress Log (`.ralph/progress.txt`)

A plain text file where agents document their work, decisions, and learnings.

### 3. Agent Prompt (`AGENT_PROMPT.md`)

The reusable prompt given to the AI agent each iteration.

### 4. Initialization Script (`.ralph/init.sh`)

A script that sets up and runs the development environment.

### 5. Loop Script (`ralph.sh`)

The bash script that orchestrates the agent loop in either:

- **Human-in-the-loop mode** (default): Runs one iteration, pauses for review
- **Continuous AFK mode**: Runs until all features complete

### 6. Ralph Directory (`.ralph/`)

All Ralph workflow files are stored in this directory which is gitignored to prevent accidental commits to the codebase.

---

## How It Works

### Two-Phase Approach

**Phase 1: Initializer Agent** (First run only)

- Creates the initial project structure
- Creates `.ralph/` directory and adds to `.gitignore`
- Generates comprehensive `.ralph/prd.json` from requirements
- Sets up `.ralph/progress.txt` and `.ralph/init.sh`
- Makes initial git commit

**Phase 2: Coding Agent** (All subsequent runs)

- Gets bearings (reads git log, .ralph/progress.txt, .ralph/prd.json)
- Tests existing functionality
- Implements ONE feature
- Verifies end-to-end with testing tools
- Updates `.ralph/prd.json` only if fully verified
- Logs to .ralph/progress.txt and commits

### Key Principles

1. **One Feature Per Iteration**: Never attempt multiple features in a single session
2. **Clean State**: Always leave code in a mergeable state with no bugs
3. **Comprehensive Testing**: Use browser automation and end-to-end tests
4. **Clear Documentation**: Update progress log and write descriptive commits
5. **Incremental Progress**: Small, verified steps prevent context overflow

---

## File Templates

See the companion files in this directory:

- `prd.json.template` - Example feature list structure
- `AGENT_PROMPT.md` - Ready-to-use agent prompt
- `ralph.sh` - Bash orchestration script
- `init.sh.template` - Example initialization script

---

## Common Failure Modes & Solutions

| Problem                                       | Solution                                               |
| --------------------------------------------- | ------------------------------------------------------ |
| Agent declares victory too early              | Comprehensive feature list with explicit pass/fail     |
| Agent tries to do too much at once            | Enforce one-feature-per-iteration rule                 |
| Code left in broken/undocumented state        | Require testing, progress logging, and git commits     |
| Features marked done without proper testing   | Mandate browser automation and end-to-end verification |
| Agent wastes time figuring out how to run app | Provide `.ralph/init.sh` script                        |
| Ralph files accidentally committed to repo    | Store all workflow files in gitignored `.ralph/` dir   |

---

## Getting Started

### First-Time Setup

1. Create your initial requirements in a simple text file
2. Run the initializer agent with initialization prompt
3. Review generated `.ralph/prd.json` and adjust if needed
4. Verify `.ralph/` is in `.gitignore`
5. Start the Ralph loop:
   - Human-in-the-loop: `./ralph.sh` (recommended for learning)
   - Continuous mode: `RUN_MODE=continuous ./ralph.sh` (for AFK runs)

### For Existing Projects

1. Create `.ralph/` directory: `mkdir -p .ralph`
2. Add to gitignore: `echo ".ralph/" >> .gitignore`
3. Manually create `.ralph/prd.json` with your feature list
4. Create empty `.ralph/progress.txt`
5. Ensure your project has git initialized
6. Start the Ralph loop:
   - Human-in-the-loop: `./ralph.sh`
   - Continuous mode: `RUN_MODE=continuous ./ralph.sh`

---

## References

- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Geoffrey Huntley: Ralph Wiggum as a "software engineer"](https://ghuntley.com/ralph/)

---

## Exit Condition

When all features in `.ralph/prd.json` have `"passes": true`, the agent outputs:

```
PROMISE COMPLETE
```

This signals the loop can terminate successfully.
