# Ralph Wiggum Technique - Complete Implementation Kit

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world."

A complete, ready-to-use system for autonomous, incremental software development using AI agents in a continuous loop.

## 🎯 What Is This?

The Ralph Wiggum Technique enables AI coding agents to build complex applications systematically across multiple sessions/context windows. Instead of trying to build everything at once, the agent works on ONE feature at a time, tests it thoroughly, and leaves clear documentation for the next session.

**Why "Ralph Wiggum"?** Named after The Simpsons character, the technique embraces simplicity over cleverness. Like Ralph showing up every day with innocent enthusiasm, this approach takes small, methodical steps rather than trying to solve everything at once—and that predictability is exactly what makes it work.

**👀 Want to see it in action?** Check out [`EXAMPLE_OUTPUT.txt`](EXAMPLE_OUTPUT.txt) for a complete real-world iteration showing Ralph selecting a feature, implementing it, and committing changes.

Based on:

- [Matt Pocock's YouTube video: "Ship working code while you sleep with the Ralph Wiggum technique"](https://www.youtube.com/watch?v=_IK18goX4X8)
- [Dex & Geoffrey Huntley: "Ralph Wiggum Methodology - Bash Loop vs. Anthropic Plugin"](https://www.youtube.com/watch?v=SB6cO97tfiY) - Deep dive into deterministic bash-loop approach vs auto-compaction
- [Anthropic's research on long-running agent harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Geoffrey Huntley's Ralph Wiggum loop pattern](https://ghuntley.com/ralph/)

> **Note:** This is a complete production toolkit for building applications across multiple sessions. If you're looking for the official [Claude Code plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) for in-session loops, that's different—it's great for iterative refinement within a single session. This implementation focuses on **systematic multi-session development** with git integration, structured PRDs, dependency tracking, and safety features.

## 📦 What's Included

This kit contains everything you need:

| File                            | Purpose                                        |
| ------------------------------- | ---------------------------------------------- |
| `The Ralph Wiggum Technique.md` | Comprehensive explanation of the technique     |
| `AGENT_PROMPT.md`               | **Ready-to-use prompt for coding agents**      |
| `INITIALIZER_PROMPT.md`         | **Prompt for first-time project setup**        |
| `prd.json.template`             | Example feature list structure                 |
| `ralph.sh`                      | Bash script to orchestrate the agent loop      |
| `init.sh.template`              | Example development environment script         |
| `EXAMPLE_OUTPUT.txt`            | **Real example of a complete Ralph iteration** |
| `README.md`                     | This file - quick start guide                  |

## 📁 Using Ralph Across Multiple Projects

Ralph lives in `/code/ralph` as your **toolkit directory**. To use it in other projects, create a wrapper script:

```bash
# In your project directory (e.g., ~/code/my-project/)
# Create ralph-local.sh
cat > ralph-local.sh << 'EOF'
#!/bin/bash
# Wrapper to run Ralph with correct paths

RALPH_DIR="$HOME/code/ralph"
AGENT_PROMPT_FILE="$RALPH_DIR/AGENT_PROMPT.md" \
  "$RALPH_DIR/ralph.sh" "$@"
EOF

chmod +x ralph-local.sh
```

Then run Ralph in your project:

```bash
./ralph-local.sh          # Human-in-the-loop mode
RUN_MODE=continuous ./ralph-local.sh  # Continuous mode
```

**Or** add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export RALPH_DIR="$HOME/code/ralph"
alias ralph="AGENT_PROMPT_FILE=$RALPH_DIR/AGENT_PROMPT.md $RALPH_DIR/ralph.sh"
```

Then use `ralph` from any project directory!

---

## 🚀 Quick Start

### Option 1: New Project (Recommended)

1. **Describe your project** in a text file:

   ```
   Build a todo list web app with:
   - Add/edit/delete todos
   - Mark as complete
   - Filter by status
   - Persist to local storage
   ```

2. **Run the initializer agent**:

   - Open your AI agent (Cursor, Claude, etc.)
   - Give it `INITIALIZER_PROMPT.md` + your requirements
   - Let it create `.ralph/` directory with `prd.json`, `progress.txt`, `init.sh`, and project structure

3. **Start the Ralph loop**:

   **Human-in-the-Loop (Recommended for learning):**

   ```bash
   ./ralph.sh
   ```

   Runs one iteration, pauses for review, then you run it again.

   **Continuous AFK Mode:**

   ```bash
   RUN_MODE=continuous ./ralph.sh
   ```

   Runs continuously until all features complete.

   **Docker Sandboxed Mode (🔒 Maximum Security):**

   ```bash
   ./ralph-docker.sh
   ```

   Runs in isolated Docker container with:
   - No host system access (only project directory)
   - No permission prompts (bypasses IDE permissions)
   - Clean CTRL-C handling (no double press needed)
   - Reproducible Ubuntu environment

   See [CONTINUOUS_MODE_IMPROVEMENTS.md](CONTINUOUS_MODE_IMPROVEMENTS.md) for details.

4. **Watch it build**: The agent will implement features one by one, test each thoroughly, and commit progress.

### Option 2: Existing Project

1. **Create `.ralph/` directory and ignore it**:
   ```bash
   mkdir -p .ralph
   echo ".ralph/" >> .gitignore
   ```
2. **Manually create `.ralph/prd.json`** using `prd.json.template` as reference
3. **Create empty `.ralph/progress.txt`**:
   ```bash
   echo "=== Ralph Wiggum Progress Log ===" > .ralph/progress.txt
   echo "Started: $(date)" >> .ralph/progress.txt
   ```
4. **(Optional) Create `.ralph/init.sh`** if you need automated dev server startup:

   ```bash
   # Copy and adapt the template
   cp init.sh.template .ralph/init.sh
   chmod +x .ralph/init.sh
   # Edit to match your project's needs
   ```

   **Note:** Most existing projects don't need this - the agent can use your existing npm/pnpm scripts.

5. **Ensure git is initialized**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```
6. **Start the loop**:

   ```bash
   # Human-in-the-loop (one iteration at a time)
   ./ralph.sh

   # OR continuous mode (runs until complete)
   RUN_MODE=continuous ./ralph.sh
   ```

## 🧭 Planning Mode → Ralph Workflow (Recommended)

For complex projects, use **Cursor Planning Mode** to design the architecture, then convert that plan into a Ralph-compatible PRD for execution.

### Why This Approach?

| Phase | Tool | Purpose |
|-------|------|---------|
| **Planning** | Cursor Planning Mode | Think, design, architect, decide *what* to build |
| **Execution** | Ralph | Build, test, commit, verify *one feature at a time* |

**Key Benefits:**
- 🎯 **Planning Mode** maintains full project context for architecture decisions
- ⚡ **Ralph Mode** executes incrementally with fresh context per feature
- 🔄 **Best of Both**: Strategic thinking + tactical implementation

### Quick Workflow

1. **Use Planning Mode to generate feature list**:

   In Cursor, enter Planning Mode with this prompt:

   ```
   I need help planning [PROJECT DESCRIPTION].

   Break this into features following Ralph PRD structure:
   - id: 3-digit number (001, 002, etc.)
   - type: feature/bug/refactor/test/spike
   - category: setup/infrastructure/functional/testing/quality/documentation
   - priority: critical/high/medium/low
   - description: Clear 1-sentence description
   - steps: 5-10 concrete implementation steps
   - estimated_complexity: small/medium/large
   - depends_on: Array of prerequisite feature IDs
   - test_files: Expected test file paths

   Output in a format easy to convert to JSON.
   ```

2. **Convert planning output to `.ralph/prd.json`**:
   - Use `.ralph/prd.json.template` as reference
   - Structure planning output as valid JSON
   - Validate with: `python3 -m json.tool .ralph/prd.json`

3. **Run Ralph** to execute the plan:
   ```bash
   ./ralph.sh  # Execute features one by one
   ```

### Full Guide

See **[PLANNING_TO_PRD.md](PLANNING_TO_PRD.md)** for:
- Complete step-by-step workflow
- Prompt templates for Planning Mode
- Examples of plan → PRD conversion
- Best practices for granularity, dependencies, complexity
- Troubleshooting common issues

**TL;DR:** Planning Mode designs the roadmap, Ralph builds it incrementally.

---

## 🎓 How It Works

### Two Phases

**Phase 1: Initialization** (first run only)

- Analyzes requirements
- Creates comprehensive feature list (`prd.json`)
- Sets up dev environment
- Configures testing infrastructure

**Phase 2: Incremental Development** (continuous loop)

```
1. Get bearings (read git log, progress, PRD)
   ↓
2. Test existing functionality
   ↓
3. Select ONE feature to implement
   ↓
4. Implement with clean code
   ↓
5. Test thoroughly (unit + e2e + browser automation)
   ↓
6. Update .ralph/prd.json (mark as passing)
   ↓
7. Log to .ralph/progress.txt
   ↓
8. Git commit
   ↓
9. Repeat until all features pass
```

### Key Files

**`.ralph/prd.json`** - The Feature List (Schema v2.0)

```json
{
  "schema_version": "2.0",
  "features": [
    {
      "id": "001",
      "type": "feature",
      "category": "functional",
      "priority": "high",
      "description": "User can add a new todo item",
      "steps": [
        "Click 'Add Todo' button",
        "Enter todo text",
        "Press Enter or click Save",
        "Verify todo appears in list"
      ],
      "estimated_complexity": "medium",
      "depends_on": [],
      "passes": false, // Agent changes to true when complete
      "iterations_taken": 0,
      "blocked_reason": null
    }
  ]
}
```

**New Schema Features:**

- `type`: Feature type - `feature`, `bug`, `refactor`, or `test`
- `depends_on`: Array of feature IDs that must complete first
- `estimated_complexity`: Size estimate - `small`, `medium`, or `large`
- `iterations_taken`: Automatically tracked by agent
- `blocked_reason`: Explanation if feature is blocked

**`.ralph/progress.txt`** - The Agent's Memory

- What was worked on
- What challenges were faced
- What decisions were made
- What's next

**`.ralph/init.sh`** - Quick Environment Setup (Optional)

- Installs dependencies
- Starts dev server
- Used by agent to test features
- **Only needed for new projects or complex setups**
- Existing projects can use standard npm/pnpm scripts instead

**Note:** All Ralph workflow files are stored in `.ralph/` directory which is gitignored to prevent accidental commits.

## 📋 Usage Examples

### Give to Agent (Cursor, Claude, etc.)

**For new projects:**

```
I want to use the Ralph Wiggum Technique to build [your project].

Here are my requirements:
[paste your requirements]

Please read and follow: INITIALIZER_PROMPT.md
```

**For coding iterations:**

```
Continue implementing features using the Ralph Wiggum Technique.

Please read and follow: AGENT_PROMPT.md
```

### Running Ralph

**Two Modes Available:**

**1. Human-in-the-Loop Mode (Default)**

```bash
./ralph.sh
```

- Runs ONE iteration then stops
- Perfect for learning, debugging, and complex features
- Review changes after each iteration
- Run again when ready: `./ralph.sh`

**2. Continuous AFK Mode**

```bash
RUN_MODE=continuous ./ralph.sh
```

- Runs until all features complete or max iterations reached
- Great for overnight runs
- Autonomous operation

**Configure AI Agent:**
Edit the top of `ralph.sh` to set your preferred agent:

- `AI_AGENT_MODE=claude` (default)
- `AI_AGENT_MODE=manual` (interactive prompts)
- `AI_AGENT_MODE=cursor` (Cursor CLI)
- `AI_AGENT_MODE=custom` (your own command)

## 🎯 Best Practices

### ✅ DO:

- Break features into atomic, testable pieces
- Use browser automation for UI testing
- Run type checking and linters
- Write descriptive commit messages
- Keep features small (implementable in one session)
- Test thoroughly before marking complete

### ❌ DON'T:

- Try to implement multiple features at once
- Mark features complete without testing
- Delete or modify feature descriptions
- Leave code in a broken state
- Skip git commits
- Assume code works without verification

## 🛡️ Error Recovery & Safety

Ralph includes automatic error recovery:

**Automatic Rollback:**

```bash
# Enabled by default
ROLLBACK_ON_FAILURE=true ./ralph.sh
```

- Automatically runs tests after each commit
- Rolls back the commit if tests fail
- Marks feature as potentially blocked

**Verification Tests:**

```bash
# Enabled by default
VERIFY_BEFORE_COMPLETE=true ./ralph.sh
```

- Runs code quality gates: formatting, linting, type checking, tests
- Only accepts commits if all quality gates pass
- See "Code Quality Gates" section below for details

**Disable for manual control:**

```bash
ROLLBACK_ON_FAILURE=false VERIFY_BEFORE_COMPLETE=false ./ralph.sh
```

## 🎨 Code Quality Gates

Ralph enforces strict code quality standards before marking features complete. When `VERIFY_BEFORE_COMPLETE=true` (default), the following checks run automatically:

### Quality Gate 1: Code Formatting

```bash
# Auto-fix enabled by default
AUTOFIX_PRETTIER=true ./ralph.sh
```

- Checks prettier/black/gofmt formatting
- Auto-fixes formatting issues before verification (if enabled)
- **Status**: Blocks completion if formatting fails
- **Fix**: `npm run format` or `prettier --write .`

### Quality Gate 2: Linting (BLOCKING)

```bash
# Runs automatically
npm run lint
```

- Checks for code quality issues, bugs, style violations
- **Status**: **ALWAYS BLOCKS** feature completion
- Linting is NOT optional - errors must be fixed
- **Fix**: Address linting errors before marking feature complete

### Quality Gate 3: Type Checking (BLOCKING)

```bash
# Runs automatically if TypeScript detected
npm run typecheck  # or tsc --noEmit
```

- Validates TypeScript types, Python type hints, etc.
- **Status**: **ALWAYS BLOCKS** feature completion if configured
- Zero type errors required
- **Fix**: Resolve type errors before marking feature complete

### Quality Gate 4: Test Suite (BLOCKING)

```bash
# Runs automatically if tests exist
npm test
```

- Runs full test suite
- **Status**: **ALWAYS BLOCKS** feature completion if tests fail
- Existing tests must not break
- New features should have test coverage
- **Fix**: Fix failing tests before marking feature complete

### Quality Gate 5: Test Coverage (BLOCKING for feature/bug types)

```bash
# Enabled by default
TEST_REQUIRED_FOR_FEATURES=true ./ralph.sh
```

**This gate ensures new functionality has tests - a core Ralph philosophy.**

#### How It Works

Ralph checks the feature `type` and enforces test requirements:

- **`feature` type**: MUST have tests - feature cannot pass without them
  - If `test_files` specified in PRD: verifies those files exist
  - Otherwise: warns but allows (backward compatible)
- **`bug` type**: MUST follow **TDD Red-Green workflow**
  1. **RED**: Write a failing test that reproduces the bug first
  2. **Verify RED**: Run test and confirm it fails (proves bug exists)
  3. **Fix**: Implement the minimal fix for the bug
  4. **GREEN**: Run test and confirm it passes (proves fix works)
  - This creates a regression test preventing the bug from returning
  - If `test_files` specified in PRD: verifies those files exist
  - Otherwise: warns but allows (backward compatible)
- **`refactor` type**: No new tests required - existing tests prove behavior unchanged
- **`test` type**: You are writing tests - this is the implementation

#### Specifying Test Files in PRD

Add optional `test_files` field to your features:

```json
{
  "id": "042",
  "type": "feature",
  "description": "User can login with email and password",
  "test_files": [
    "tests/auth.test.js",
    "tests/login.test.js"
  ],
  "passes": false
}
```

When specified, Ralph will **verify these files exist** before marking the feature complete.

#### Why This Matters

1. **Prevents regressions**: Tests catch bugs before they reach production
2. **Documents behavior**: Tests serve as executable documentation
3. **Enables refactoring**: Comprehensive tests make future changes safe
4. **Builds confidence**: Green tests mean features work as intended

#### TDD Red-Green Workflow for Bug Fixes

Ralph enforces Test-Driven Development (TDD) for bug fixes to ensure quality and prevent regressions:

**The Red-Green Workflow:**

1. **🔴 RED - Write Failing Test**
   - Before fixing anything, write a test that reproduces the bug
   - The test should fail when run against the current buggy code
   - This proves the bug is real and reproducible

2. **🔴 Verify RED - Confirm Test Fails**
   - Run the test and verify it fails with the expected error
   - If the test passes, you haven't reproduced the bug correctly
   - Document the failing test output in your progress notes

3. **🔧 Fix - Implement Minimal Fix**
   - Now implement the fix to make the test pass
   - Keep the fix minimal and focused on the bug
   - Don't add extra features or refactoring

4. **✅ GREEN - Verify Test Passes**
   - Run the test again and confirm it now passes
   - This proves your fix actually resolves the bug
   - The test now serves as a permanent regression test

**Why TDD for Bugs?**

- **Proves reproducibility**: If you can't write a failing test, can you really fix it?
- **Proves the fix works**: Green test = bug is actually fixed
- **Prevents regression**: The test will catch the bug if it returns
- **Documents the issue**: The test shows exactly what was broken
- **Builds confidence**: You know the fix works because you saw RED → GREEN

**Example Bug Fix Process:**

```bash
# 1. RED - Write test that reproduces bug
echo "Writing test for login bug..."
cat > tests/login-bug.test.js

# 2. Verify RED - Run test, see it fail
npm test tests/login-bug.test.js
# ❌ Expected: user logged in, Got: null

# 3. Fix - Implement the fix
# Edit src/auth.js to fix the bug

# 4. GREEN - Verify test passes
npm test tests/login-bug.test.js
# ✅ All tests passing
```

This workflow is **mandatory for type='bug'** features in Ralph.

#### Configuration

```bash
# Enforce test requirements (default)
TEST_REQUIRED_FOR_FEATURES=true ./ralph.sh

# Disable test enforcement (not recommended)
TEST_REQUIRED_FOR_FEATURES=false ./ralph.sh
```

**Recommendation**: Keep this enabled. Tests are not optional for quality software.

### Configuration Options

```bash
# Default: auto-fix prettier formatting before checks
AUTOFIX_PRETTIER=true ./ralph.sh

# Disable auto-fix (will still check formatting)
AUTOFIX_PRETTIER=false ./ralph.sh

# Disable all verification (not recommended)
VERIFY_BEFORE_COMPLETE=false ./ralph.sh
```

### Quality Gate Results

Ralph provides a clear summary after running checks:

```
Quality Gate Summary:
  ✅ Formatting
  ✅ Linting
  ✅ Type Checking
  ✅ Tests
  ✅ Test Coverage

✅ ALL QUALITY GATES PASSED
```

Or if failures occur:

```
Quality Gate Summary:
  ✅ Formatting
  ❌ Linting
  ❌ Type Checking
  ✅ Tests
  ❌ Test Coverage

❌ QUALITY GATES FAILED - Feature cannot be marked complete
```

**Important**: Features CANNOT be marked as `"passes": true` in `prd.json` until ALL quality gates pass.

## 🐳 Sandboxed Execution (Docker)

Ralph includes `ralph-docker.sh` for running in complete isolation using Docker containers.

### Why Use Docker?

**Security Benefits:**
- **Isolated Environment**: Ralph runs with ZERO access to your host system
- **Volume-Only Access**: Only your project directory is accessible (read-write)
- **No Permission Prompts**: Bypasses IDE permission systems entirely
- **Clean Shutdown**: Single CTRL-C works (no double-press issue)
- **Reproducible**: Same Ubuntu 22.04, Node.js 20.x, Python 3 environment every time

**Perfect for:**
- Overnight continuous mode runs
- Untrusted or experimental code
- Remote server deployments
- Avoiding permission interruptions

### Quick Start

```bash
# First run: Builds Docker image (~2 minutes)
./ralph-docker.sh

# Subsequent runs: Uses cached image
./ralph-docker.sh

# Limit iterations
MAX_ITERATIONS=50 ./ralph-docker.sh

# Force rebuild after Dockerfile changes
REBUILD=true ./ralph-docker.sh
```

### What Gets Mounted

**Only these directories are accessible to Ralph:**

1. **Project Directory** (read-write): Your code, .ralph/, git repo
2. **.cursor Config** (read-only): API keys for Cursor integration

**NOT accessible**: Your home directory, system files, other projects, SSH keys

### Environment Variables

All standard Ralph settings work in Docker:

```bash
# Core settings
ANTHROPIC_API_KEY=your-key    # For Claude CLI
RUN_MODE=continuous           # Default in Docker
MAX_ITERATIONS=100            # Limit iterations

# Ralph configuration
LOG_LEVEL=DEBUG               # Verbose logging
TEST_OUTPUT_MODE=failures     # Show only failures

# Docker-specific
REBUILD=true                  # Force image rebuild
DOCKER_IMAGE_NAME=ralph-env   # Custom image name
```

### Comparison: Docker vs Standard Mode

| Feature                    | Standard Mode    | Docker Mode    |
| -------------------------- | ---------------- | -------------- |
| Host System Access         | Full             | **None**       |
| Permission Prompts         | May interrupt    | **None**       |
| CTRL-C Behavior            | May need 2×      | **Clean 1×**   |
| Setup Time                 | Instant          | ~2 min first   |
| Environment Consistency    | Varies by system | **Guaranteed** |
| Overhead                   | None             | Minimal        |
| Best For                   | Development      | Production     |

### Advanced Usage

**Custom Dockerfile:**
Edit the Dockerfile section in `ralph-docker.sh`:

```bash
# Add your custom dependencies
RUN apt-get install -y postgresql-client redis-tools

# Install project-specific tools
RUN npm install -g your-global-package
```

Then rebuild:

```bash
REBUILD=true ./ralph-docker.sh
```

**Troubleshooting:**

See [CONTINUOUS_MODE_IMPROVEMENTS.md](CONTINUOUS_MODE_IMPROVEMENTS.md#solution-3-docker-setup-for-safe-continuous-mode--implemented) for:
- Docker installation instructions
- Common issues and solutions
- Volume mount configuration
- Performance tuning

## 📊 Feature Dependencies & Acceptance Criteria

### Feature Dependencies

Features can declare dependencies using the `depends_on` field:

```json
{
  "id": "005",
  "description": "User can delete a todo",
  "depends_on": ["001", "003"], // Needs create and display first
  "passes": false
}
```

The agent will automatically skip features with unmet dependencies.

### Acceptance Criteria

Ralph supports structured acceptance criteria to make testing requirements explicit:

```json
{
  "id": "004",
  "description": "User can submit form with validation",
  "test_files": ["tests/form-validation.test.js"],
  "acceptance_criteria": {
    "unit_tests": [
      "tests/form-validation.test.js",
      "tests/validators.test.js"
    ],
    "e2e_tests": [
      "tests/e2e/form-submit-valid.spec.js",
      "tests/e2e/form-submit-invalid.spec.js"
    ],
    "manual_checks": [
      "Error messages are clear and actionable",
      "Form submits only when all fields are valid",
      "Success message displays after submission"
    ]
  }
}
```

**Benefits:**
- **Explicit test requirements**: Specify exactly which test files must exist
- **Structured approach**: Separate unit tests, e2e tests, and manual checks
- **Quality gate enforcement**: Ralph verifies all test files exist before completion
- **Clear guidance**: Manual checks provide verification steps for agents

**How it works:**
1. Agent reads acceptance_criteria from PRD when working on feature
2. Agent creates all specified test files during implementation
3. Quality Gate 5 verifies all test files from acceptance_criteria exist
4. Manual checks are displayed to remind agent of verification steps
5. Feature cannot pass without all required test files

**Note:** acceptance_criteria is optional but recommended, especially for features with complex testing requirements. It works alongside the simpler test_files field.

## 🐛 Common Issues

### "Agent tries to do too much at once"

- Make features smaller in `.ralph/prd.json`
- Use `estimated_complexity` to keep features small
- Emphasize "ONE feature per iteration" in prompt

### "Agent marks features complete without testing"

- Automatic verification is now enabled by default
- Ensure browser automation tools are available
- Add explicit testing steps to each feature

### "Tests fail after implementation"

- Automatic rollback will revert the commit
- Check rollback logs for failure details
- Feature will need to be reworked

### "Feature is blocked"

- Set `"blocked_reason"` in PRD with explanation
- Agent will skip blocked features
- Document blocker in progress.txt

### "Dependency chain is broken"

- Check `depends_on` arrays in PRD
- Ensure all dependencies have `"passes": true`
- Agent automatically skips features with unmet dependencies

### "Code gets messy over time"

- Add `type: "refactor"` features to `.ralph/prd.json`
- Run linters after each iteration
- Review and refactor periodically

### "Agent loses context between sessions"

- Ensure `.ralph/progress.txt` has detailed notes
- Write descriptive git commits
- Include "next steps" in progress log

### "Ralph files accidentally committed to git"

- The `.ralph/` directory should be in `.gitignore`
- Initializer agent creates this automatically
- For existing projects, add manually: `echo ".ralph/" >> .gitignore`

## 🔧 Customization

### For Different Project Types

**Web Apps**: Include browser automation (Playwright/Puppeteer)
**APIs**: Focus on endpoint testing with curl/supertest
**Libraries**: Emphasize unit tests and examples
**CLIs**: Test with actual command execution

### Adjust Iterations

```bash
# Continuous mode with custom iteration limit
MAX_ITERATIONS=50 RUN_MODE=continuous ./ralph.sh

# Human-in-the-loop always runs just 1 iteration
./ralph.sh
```

### Git Safety Options

Ralph includes built-in safety features to prevent accidental commits to important branches and unauthorized pushes:

```bash
# Work on a feature branch (required - protected branches blocked by default)
git checkout -b feature/my-feature
./ralph.sh

# Override protected branches (not recommended)
PROTECTED_BRANCHES="" ./ralph.sh

# Change which branches are protected (default: main,master)
PROTECTED_BRANCHES="main,master,production" ./ralph.sh

# Enable git push operations (disabled by default for safety)
ALLOW_GIT_PUSH=true ./ralph.sh
```

**Safety Features:**

- **Protected Branches**: By default, Ralph will exit with an error if you try to run it on `main` or `master` branches
- **No Push by Default**: Git push operations are blocked unless `ALLOW_GIT_PUSH=true` is set
- **Feature Branch Workflow**: Encourages working on feature branches to keep main clean
- **Helpful Error Messages**: Provides clear instructions when safety checks fail

**Best Practice**: Always work on a feature branch:

```bash
git checkout -b feature/add-authentication
./ralph.sh
```

#### Auto-Branch Creation (New!)

Ralph can automatically create feature branches when you run it on a protected branch (like `main` or `master`). This eliminates the manual step of creating branches!

**How it works:**

1. Run Ralph on a protected branch (e.g., `main`)
2. Ralph inspects your PRD to find the next feature to implement
3. Ralph auto-generates a branch name based on the feature type and description
4. Ralph creates and switches to the new branch
5. Ralph proceeds with the iteration

**Branch naming convention:**

- `feature/{id}-{slug}` - for type: "feature"
- `bugfix/{id}-{slug}` - for type: "bug"
- `refactor/{id}-{slug}` - for type: "refactor"
- `test/{id}-{slug}` - for type: "test"

Example: Feature `000a` with description "Auto-create feature branches..." becomes:

```
feature/000a-auto-create-feature-branches
```

**Usage:**

```bash
# Auto-create branch (enabled by default)
cd /path/to/your/project
git checkout main
./ralph.sh
# Ralph detects protected branch, inspects PRD, creates feature/000a-auto-create-feature-branches

# Specify custom branch name
./ralph.sh --branch-name my-custom-branch

# Disable auto-creation (require manual branch creation)
AUTO_CREATE_BRANCH=false ./ralph.sh

# Help
./ralph.sh --help
```

**Configuration:**

```bash
# Enable/disable auto-branch creation (default: true)
AUTO_CREATE_BRANCH=true ./ralph.sh

# Custom branch name via parameter
./ralph.sh --branch-name feature/my-custom-feature

# Works with other options
RUN_MODE=continuous AUTO_CREATE_BRANCH=true ./ralph.sh
```

**Benefits:**

- ✅ No more manually creating feature branches
- ✅ Consistent branch naming across your project
- ✅ Branch names match the feature being implemented
- ✅ Safe to run Ralph on main - it automatically moves to a feature branch
- ✅ Conventional branch prefixes (feature/, bugfix/, etc.) for better organization

### Logging and Error Handling

Ralph includes comprehensive logging and error handling features (Feature 007) to help diagnose issues and monitor execution.

#### Log Levels

Control the verbosity of output with log levels:

```bash
# Default: Show info, warnings, and errors
./ralph.sh

# Debug mode: Show all messages including debug info
./ralph.sh --verbose
LOG_LEVEL=DEBUG ./ralph.sh

# Quiet mode: Show only errors
./ralph.sh --quiet
LOG_LEVEL=ERROR ./ralph.sh

# Warning mode: Show warnings and errors
LOG_LEVEL=WARN ./ralph.sh
```

**Log Level Hierarchy:**
- `DEBUG`: Most verbose - shows tool checks, internal operations, all messages
- `INFO`: Normal verbosity - shows informational messages, warnings, errors (default)
- `WARN`: Shows only warnings and errors
- `ERROR`: Least verbose - shows only error messages

#### Persistent Logging

Save logs to a file for later analysis:

```bash
# Log to file
LOG_FILE=".ralph/ralph.log" ./ralph.sh

# Tail logs in real-time
tail -f .ralph/ralph.log

# Review logs later
less .ralph/ralph.log

# Combine with verbose mode
LOG_LEVEL=DEBUG LOG_FILE=".ralph/ralph.log" ./ralph.sh
```

**Log file format:**
```
[2025-01-26 10:30:15] [INFO] Checking prerequisites...
[2025-01-26 10:30:15] [DEBUG] ✓ git is installed
[2025-01-26 10:30:15] [DEBUG] ✓ python3 is installed
[2025-01-26 10:30:16] [SUCCESS] Prerequisites check complete
```

#### Health Check Command

Run a comprehensive health check to verify your Ralph setup:

```bash
./ralph.sh --doctor
```

**What it checks:**
1. **Required Tools**: git, python3, curl are installed
2. **Git Repository**: Repository exists, current branch status
3. **.ralph Directory**: PRD file, progress file, valid JSON structure
4. **Agent Prompt**: AGENT_PROMPT.md exists
5. **Configuration**: All configuration values are displayed
6. **Sanity**: Validates Sanity config if PRD_STORAGE=sanity
7. **Quality Gates**: Checks for lint, test, typecheck, format scripts

**Example output:**
```
╔════════════════════════════════════════╗
║   Ralph Wiggum Health Check (Doctor)  ║
╚════════════════════════════════════════╝

[INFO] 1/7 Checking required tools...
[SUCCESS] ✓ All required tools are installed

[INFO] 2/7 Checking git repository...
[SUCCESS] ✓ Git repository exists
[INFO]   Current branch: feature/my-feature
[SUCCESS]   ✓ Branch is safe for commits

...

════════════════════════════════════════
[SUCCESS] 🎉 All checks passed! Ralph is ready to run.
```

#### Tool Verification

Ralph automatically checks for required tools before running:

**Required tools:**
- `git` - Version control
- `python3` - JSON parsing and PRD manipulation
- `curl` - HTTP requests (for Sanity integration)

**Optional tools:**
- `node` / `npm` - JavaScript quality gates
- `jq` - JSON parsing (Python used as fallback)

If a required tool is missing, Ralph provides installation instructions:
```
[ERROR] ✗ python3 is not installed or not in PATH
[INFO]   Install with: brew install python3 (macOS) or apt-get install python3 (Linux)
```

#### Troubleshooting Guide

For common issues and solutions, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

The guide includes:
- Quick health check instructions
- Common error messages and solutions
- Installation instructions for missing tools
- Protected branch issues
- PRD validation errors
- Quality gate failures
- Sanity connection problems
- Verbose logging examples
- Configuration debugging

**Quick troubleshooting:**
```bash
# 1. Run health check
./ralph.sh --doctor

# 2. Enable verbose logging
./ralph.sh --verbose

# 3. Check logs
tail -50 .ralph/progress.txt

# 4. Validate PRD
python3 -m json.tool .ralph/prd.json
```

#### Error Messages with Context

Ralph provides helpful error messages with suggestions:

**Before (generic):**
```
Error: File not found
```

**After (helpful):**
```
[ERROR] PRD file not found: .ralph/prd.json
[INFO] Run the initializer agent first, or create .ralph/ directory manually
```

**Graceful degradation:**
- Missing optional tools don't block execution
- Helpful suggestions for fixing issues
- Clear indication of what's required vs optional
- Installation hints for common package managers

### Test Output Optimization (Feature 011)

Ralph optimizes test output to conserve tokens when working with AI coding agents. Instead of showing hundreds of lines of passing tests, Ralph displays only what's needed.

#### TEST_OUTPUT_MODE Configuration

Control how much test output is shown:

```bash
# Default: Show summary + only failing tests (optimal)
TEST_OUTPUT_MODE=failures ./ralph.sh

# Show only statistics (most concise)
TEST_OUTPUT_MODE=summary ./ralph.sh

# Show everything (original behavior)
TEST_OUTPUT_MODE=full ./ralph.sh
```

**Output Modes:**

1. **`failures` (default - recommended)**
   - Shows test summary statistics
   - Shows only failing test details
   - Optimal balance of information and token usage
   - Best for most workflows

2. **`summary`**
   - Shows only test statistics (total, passed, failed, skipped)
   - Most concise - minimal token usage
   - Good when you just need to know pass/fail status

3. **`full`**
   - Shows complete test output
   - Original behavior before Feature 011
   - Use when debugging test infrastructure

#### Example Output

**When tests pass (failures mode):**
```
🧪 Quality Gate 4/5: Test Suite

📊 Test Summary:
   Total:   138 tests
   Passed:  138 ✅

[SUCCESS] ✅ PASSED: Test suite
```

**When tests fail (failures mode):**
```
🧪 Quality Gate 4/5: Test Suite

📊 Test Summary:
   Total:   138 tests
   Passed:  135 ✅
   Failed:  3 ❌

❌ Failing Tests:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
not ok 42 feature should handle edge case
# Expected: true
# Received: false
not ok 87 integration test with API
# Network error: Connection refused
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ERROR] ❌ FAILED: Test suite failed (BLOCKING)
```

#### Supported Test Frameworks

Ralph's test parser supports multiple test frameworks:

- **Bats** (Bash Automated Testing System) - TAP format
- **Jest** - JavaScript/TypeScript testing
- **Vitest** - Fast Vite-native testing
- **Mocha** - JavaScript testing framework
- **Generic TAP** - Test Anything Protocol

The parser automatically detects the test format and extracts relevant information.

#### Token Savings

**Before Feature 011 (full mode):**
- 138 passing tests = ~800 lines of output = ~6,000 tokens consumed
- All test details shown even when passing

**After Feature 011 (failures mode):**
- 138 passing tests = ~7 lines of output = ~50 tokens consumed
- **99% reduction in tokens when tests pass**
- Only failures shown when needed

**Impact on continuous mode:**
- Each iteration conserves ~5,950 tokens when tests pass
- 10 iterations = ~60,000 tokens saved
- Allows more iterations within context window limits

#### Why This Matters

1. **Token Efficiency**: Maximize the number of Ralph iterations per session
2. **Signal vs Noise**: Focus on failures, not verbose passing test logs
3. **Cost Savings**: Fewer tokens = lower AI API costs
4. **Better Context**: More room for code, planning, and implementation
5. **Faster Feedback**: Quickly see what failed without scrolling

**Recommendation**: Use the default `failures` mode unless you need complete test output for debugging.

### Sanity CMS Integration

Ralph supports storing your PRD (Product Requirements Document) in Sanity CMS instead of local JSON files. This enables team collaboration, visual editing, version history, and real-time sync across multiple Ralph instances.

**Current Status:**

- ✅ **Feature 013 (Complete)**: Sanity schema definitions created
- ✅ **Feature 014 (Complete)**: Sanity API integration for read/write operations
- ⏳ **Feature 016 (Planned)**: Sanity Studio UI for PRD management

**Configuration:**

```bash
# Sanity project credentials
export SANITY_PROJECT_ID="your-project-id"
export SANITY_DATASET="production"          # default: production
export SANITY_TOKEN="your-write-token"

# Storage mode: "file" (default) or "sanity"
export PRD_STORAGE="sanity"

# Run Ralph with Sanity as source of truth
PRD_STORAGE=sanity ./ralph.sh
```

**How It Works:**

When `PRD_STORAGE=sanity`, Ralph:
- Fetches PRD from Sanity using GROQ queries (no local file required)
- Updates feature status directly in Sanity via mutations API
- Uses Sanity as the single source of truth (no file syncing)
- Validates authentication and connection on startup

**Schema Files:**

The Sanity schema definitions are available in `.ralph/sanity/schemas/`:

- `ralphProject.js` - Main PRD document schema
- `ralphFeature.js` - Individual feature schema
- `index.js` - Schema exports

**Setup Instructions:**

1. **Deploy Schemas** (choose one method):
   ```bash
   # Option A: Using Sanity CLI (if you have a local Studio)
   cd .ralph/sanity
   sanity schema deploy

   # Option B: Using MCP tools (Claude Code with Sanity MCP)
   # Use deploy_schema tool with schema files

   # Option C: Manual import via Sanity Studio
   # Copy schema files to your Studio project
   ```

2. **Get API Token**:
   - Go to https://sanity.io/manage
   - Select your project
   - Navigate to API → Tokens
   - Create a token with "Editor" permissions
   - Copy the token value

3. **Configure Environment**:
   ```bash
   export SANITY_PROJECT_ID="abc123"
   export SANITY_DATASET="production"
   export SANITY_TOKEN="sk..."
   export PRD_STORAGE="sanity"
   ```

4. **Migrate Your PRD**:
   ```bash
   # Generate Sanity document JSON
   node .ralph/sanity/migrate.js > prd-document.json

   # Import to Sanity (requires Sanity CLI)
   sanity dataset import prd-document.json production --replace

   # Or import via Sanity Studio's import UI
   ```

5. **Run Ralph**:
   ```bash
   # Ralph will now use Sanity as the source of truth
   PRD_STORAGE=sanity ./ralph.sh
   ```

**Documentation:**

See `.ralph/sanity/README.md` for:
- Complete setup instructions
- Schema deployment options
- Migration guide
- Sanity Studio integration

**Benefits:**

- 🌐 **Team Collaboration**: Multiple developers can access the same PRD
- 🎨 **Visual Editing**: Manage features through Sanity Studio UI
- 📜 **Version History**: Track all changes to features over time
- 🔄 **Real-time Sync**: Changes are immediately available across all instances
- 🔍 **Advanced Queries**: Use GROQ to query and analyze your feature backlog

**Next Steps:**

1. Deploy schemas to your Sanity project (see setup instructions above)
2. Create an API token and configure environment variables
3. Migrate your PRD using the migration script
4. Run Ralph with `PRD_STORAGE=sanity`
5. (Optional) Implement Sanity Studio UI for visual editing (Feature 016)

### Progress Header (Feature 024)

Ralph displays a persistent progress header at the top of your terminal that shows the current feature being worked on and overall completion statistics. This helps you understand what Ralph is doing and how much work remains.

**Configuration:**

```bash
# Enable progress header (default: true)
SHOW_PROGRESS_HEADER=true ./ralph.sh

# Disable progress header
SHOW_PROGRESS_HEADER=false ./ralph.sh
```

**What the header shows:**

- **Current Feature**: Feature ID, type, and description of the feature being worked on
- **Progress Stats**: Completion percentage, completed features, blocked features, remaining features

**Example Header:**

```
═══════════════════════════════════════════════════════════════════
🎯 Current: [024] - feature - Add persistent progress header
📊 Progress: 15/23 (65%) complete | 1 blocked | 7 remaining
═══════════════════════════════════════════════════════════════════
```

**Technical Implementation:**

The header uses terminal control sequences (`tput`) to:
1. Save the current cursor position
2. Move cursor to top of screen (row 0, column 0)
3. Display the header with color coding:
   - 🟢 Green: Completed features
   - 🟡 Yellow: Current/remaining features
   - 🔴 Red: Blocked features
4. Restore cursor to original position

This makes the header remain visible at the top of the terminal while Claude's output continues below.

**When it displays:**

- At the start of each Ralph iteration
- After feature selection (shows the actual selected feature, not a guess)
- Before the agent starts working

**Benefits:**

- ✅ **At-a-Glance Status**: Know what Ralph is working on without reading logs
- ✅ **Progress Tracking**: See completion percentage and remaining work
- ✅ **Context Preservation**: Header stays visible during agent execution
- ✅ **Visual Feedback**: Color-coded indicators for different states
- ✅ **Accurate Display**: Shows actual selected feature, not stale branch info

**Note:** The header respects `LOG_LEVEL=ERROR` mode and won't display in quiet mode.

### Failure Learning / Rollback Context (Feature 029)

When Ralph's quality gates fail and a commit is rolled back, the failure context is preserved in `progress.txt` so the next iteration can learn from the mistakes. This breaks the failure loop where agents repeatedly attempt the same failing approach.

**How it works:**

1. Quality gates run after commit (linting, type checking, tests, formatting)
2. If any gate fails, `git reset --hard HEAD~1` rolls back the commit
3. **BEFORE the rollback:** Ralph would lose all context about what failed
4. **AFTER Feature 029:** Ralph captures failure details and appends to `progress.txt` AFTER the rollback
5. Next iteration reads `progress.txt` and sees exactly what went wrong

**What gets captured:**

- **Feature Info**: Which feature was being worked on (ID and description)
- **Failed Gates**: Which quality checks failed (linting, type checking, tests, formatting)
- **Error Details**: Actual error messages from the failed gates:
  - Linting errors from `/tmp/ralph_lint.log`
  - Type checking errors from `/tmp/ralph_typecheck.log`
  - Test failures from `/tmp/ralph_test.log` (with specific failing tests)
  - Formatting issues from `/tmp/ralph_format_check.log`
- **Guidance**: Suggestions for the next iteration

**ROLLBACK Entry Format:**

```
--- ROLLBACK: 2025-01-28 15:30:00 ---
Feature: [029] Persist failure context after rollback
Rolled Back Commit: "feat: add failure context logging"

QUALITY GATES FAILED:
❌ Linting errors detected

ERROR DETAILS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ralph.sh:1234:15: error: unused variable 'foo'
ralph.sh:1245:22: error: missing semicolon
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GUIDANCE FOR NEXT ITERATION:
- Fix linting errors shown above
- Run `npm run lint` before marking feature complete
- Ensure all quality gates pass before committing
---
```

**How agents use this:**

The `AGENT_PROMPT.md` instructs agents to check for `ROLLBACK` entries in `progress.txt` at the start of each iteration:

1. Read `progress.txt` and look for recent `ROLLBACK` entries
2. If found, read the error details carefully
3. Avoid repeating the same mistakes
4. Apply the guidance to fix the issues

**Benefits:**

- ✅ **Break Failure Loops**: Agents learn from failed attempts instead of repeating them
- ✅ **Specific Error Context**: Actual error messages guide fixes, not generic "tests failed"
- ✅ **Persistent Learning**: Context survives rollback (not destroyed by `git reset`)
- ✅ **Incremental Debugging**: Each iteration builds on previous attempts
- ✅ **Actionable Guidance**: Clear suggestions for what to fix

**Configuration:**

Failure learning is automatically enabled when `ROLLBACK_ON_FAILURE=true` (the default). No additional configuration needed—it just works!

**Example Workflow:**

1. **Iteration 1**: Agent implements feature, commits, quality gates fail (linting errors)
2. Ralph rolls back commit but saves failure context to `progress.txt`
3. **Iteration 2**: Agent reads `ROLLBACK` entry, sees linting errors, fixes them, commits successfully
4. Feature is now complete with proper quality

### Combine Options

```bash
# Human-in-the-loop with manual agent control
RUN_MODE=once AI_AGENT_MODE=manual ./ralph.sh

# Continuous with custom files
RUN_MODE=continuous PRD_FILE=.ralph/features.json ./ralph.sh

# Feature branch with push enabled
git checkout -b feature/my-feature
ALLOW_GIT_PUSH=true ./ralph.sh

# All options combined
RUN_MODE=continuous AI_AGENT_MODE=claude MAX_ITERATIONS=50 ./ralph.sh
```

## 📊 Success Metrics

A well-running Ralph loop shows:

- ✅ Consistent commit history (1 feature = 1 commit)
- ✅ Decreasing `"passes": false` count in `.ralph/prd.json`
- ✅ Detailed progress notes in `.ralph/progress.txt` after each iteration
- ✅ Tests passing continuously (automatic verification)
- ✅ Clean, working code at all times
- ✅ `.ralph/` directory properly gitignored
- ✅ Features with dependencies completed in order
- ✅ Accurate `iterations_taken` tracking
- ✅ Minimal blocked features

## 🧪 Testing

Ralph includes a comprehensive automated test suite using [bats-core](https://github.com/bats-core/bats-core) to verify core functionality.

### Running Tests

```bash
# Install dependencies (first time only)
npm install

# Run all tests
npm test

# Run tests with verbose output
npm run test:verbose
```

### What's Tested

The test suite covers:

- **Configuration Loading** (20 tests)
  - Default configuration values
  - Environment variable overrides
  - File path configurations

- **Git Safety Features** (12 tests)
  - Protected branch detection
  - Auto-branch creation
  - Git push blocking
  - Branch naming conventions

- **Feature Selection Logic** (10 tests)
  - Priority-based selection
  - Dependency checking
  - Blocked feature filtering
  - Completion detection

- **PRD Validation** (13 tests)
  - JSON schema validation
  - Required field checks
  - Type validation
  - Test fixtures

### Test Results

All 55 tests pass successfully:

```
✓ ralph.sh script exists and is executable
✓ ralph.sh has valid bash syntax
✓ Configuration defaults are correct
✓ Git safety features work properly
✓ Feature selection respects dependencies and priority
✓ PRD JSON parsing handles all field types
```

### Continuous Integration

Tests run automatically on every push and pull request via GitHub Actions (see `.github/workflows/test.yml`).

### Test Structure

```
tests/
├── ralph-config.bats          # Configuration loading tests
├── ralph-git-safety.bats      # Git safety feature tests
├── ralph-feature-selection.bats # Feature selection logic tests
├── ralph-prd-parsing.bats     # PRD validation tests
└── fixtures/
    └── mock-prd.json          # Test fixture with sample features
```

## 🎓 Learning Resources

- **[EXAMPLE_OUTPUT.txt](EXAMPLE_OUTPUT.txt)** - See a real Ralph iteration from start to finish (feature selection, implementation, testing, commit)
- [Matt Pocock: Ship working code while you sleep (YouTube)](https://www.youtube.com/watch?v=_IK18goX4X8) - Great video introduction to the Ralph technique
- [Dex & Geoffrey Huntley: Ralph Wiggum Methodology Deep Dive (YouTube)](https://www.youtube.com/watch?v=SB6cO97tfiY) - Technical comparison of bash-loop vs plugin approaches, context engineering, and security considerations
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Geoffrey Huntley: Ralph Wiggum as a "software engineer"](https://ghuntley.com/ralph/)
- [Claude Agent SDK Documentation](https://docs.anthropic.com/en/docs/agents)

## 🤝 Contributing

This is a living document. Improvements welcome:

- Better prompt engineering
- Additional templates
- Integration examples
- Project type variations

## 📄 License

Feel free to use, modify, and distribute. Attribution appreciated.

---

**Ready to build something?** Start with `INITIALIZER_PROMPT.md` or `AGENT_PROMPT.md`!
