# Ralph Wiggum Technique - Quick Reference Card

## 🎯 Core Principle

**ONE feature per iteration. Test thoroughly. Leave clean.**

## 🚀 Quick Setup for New Projects

```bash
# In your project directory:
# 1. Create wrapper script
cat > ralph-local.sh << 'EOF'
#!/bin/bash
RALPH_DIR="$HOME/code/ralph"
AGENT_PROMPT_FILE="$RALPH_DIR/AGENT_PROMPT.md" \
  "$RALPH_DIR/ralph.sh" "$@"
EOF
chmod +x ralph-local.sh

# 2. Create .ralph directory
mkdir -p .ralph && echo ".ralph/" >> .gitignore

# 3. Create PRD and progress
cp $RALPH_DIR/prd.json.template .ralph/prd.json
echo "=== Progress ===" > .ralph/progress.txt

# 4. Run Ralph!
./ralph-local.sh
```

## 🔄 Run Modes

**Human-in-the-Loop (Default):**

```bash
./ralph.sh
```

- Runs ONE iteration then stops
- Review changes after each iteration
- Run again when ready

**Continuous AFK Mode:**

```bash
RUN_MODE=continuous ./ralph.sh
```

- Runs until all features complete
- Great for overnight runs

## 📝 Every Iteration Checklist

### 1. Get Bearings

```bash
pwd                                # Where am I?
cat .ralph/progress.txt | tail -50 # What happened recently?
git log --oneline -20              # What commits were made?
cat .ralph/prd.json                # What features remain?
```

### 2. Start Environment

```bash
# If .ralph/init.sh exists:
./.ralph/init.sh             # Start dev server

# Otherwise use standard project commands:
npm run dev                  # or pnpm dev, etc.
```

**Note:** `.ralph/init.sh` is optional for existing projects.

### 3. Test Existing Functionality

- Run basic smoke tests
- If broken, fix immediately
- Don't start new work on broken code

### 4. Select ONE Feature

- Find `"passes": false` in `.ralph/prd.json`
- Choose highest priority
- State: "I am working on: [feature]"

### 5. Implement

- Write clean code
- Follow existing patterns
- Add error handling
- Document complex logic

### 6. Test Thoroughly

```bash
# Type checking
npm run typecheck

# Tests
npm test

# Linting
npm run lint

# Browser automation (for web apps)
# Use Playwright/Puppeteer to test as user would
```

### 7. Update PRD

Only if fully verified AND all quality gates pass:

```json
"passes": false  →  "passes": true
"iterations_taken": 0  →  "iterations_taken": 1
```

**Quality Gates that MUST pass:**
- ✅ Code formatting (prettier/black)
- ✅ Linting (eslint/pylint) - BLOCKING
- ✅ Type checking (tsc/mypy) - BLOCKING
- ✅ Test suite - BLOCKING
- ✅ Test coverage - BLOCKING for feature/bug types
  - Features MUST have tests
  - Bugs MUST follow TDD red-green workflow

### 8. Log Progress

Append to `.ralph/progress.txt`:

```
--- [Date/Time] ---
Feature: [description]
Implementation: [what was built]
Testing: [what was verified]
Challenges: [issues and solutions]
Next: [suggestions]
---
```

### 9. Commit

```bash
git add -A
git commit -m "feat: [clear feature description]"
```

### 10. Check Completion

```bash
grep '"passes": false' .ralph/prd.json
```

If none found, output: `PROMISE COMPLETE`

## ⚠️ Critical Rules

### ✅ ALWAYS:

- Work on ONE feature only
- Test before marking complete
- Leave code working and clean
- Update .ralph/progress.txt
- Make git commit
- Verify with actual testing (browser/API/unit)

### ❌ NEVER:

- Multiple features at once
- Mark complete without testing
- Edit feature descriptions in .ralph/prd.json
- Leave broken code
- Skip commits
- Overwrite .ralph/progress.txt (append only)
- Assume code works without verification

## 🧪 Testing Strategies

### Web Apps

```javascript
// Use browser automation
await page.goto("http://localhost:3000");
await page.click('[data-testid="add-button"]');
await page.fill('input[name="todo"]', "Test todo");
await page.click('button[type="submit"]');
expect(await page.textContent(".todo-list")).toContain("Test todo");
```

### APIs

```bash
# Test endpoints
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test"}'

# Verify response
# Check status code
# Verify data
```

### Libraries

```javascript
// Unit tests
import { myFunction } from "./myModule";
expect(myFunction("input")).toBe("expected output");
```

## 🚨 If Things Go Wrong

### Tests Failing

1. Read error messages
2. Fix the issue
3. Verify fix works
4. Continue with feature

### Code Broken

1. `git log` - when did it break?
2. `git diff` - what changed?
3. Fix the regression
4. Verify with tests
5. Commit fix

### Stuck on Feature

1. Document blocker in .ralph/progress.txt
2. Leave `"passes": false`
3. Try different feature
4. Leave clear notes

### Context Window Full

1. Complete current feature if close
2. Otherwise, reach clean stopping point
3. Commit work
4. Detailed .ralph/progress.txt notes
5. Next session continues

## 📊 Progress Indicators

### Good Signs ✅

- One commit per feature
- Decreasing false count in .ralph/prd.json
- Detailed progress notes
- Tests passing
- Clean git history

### Warning Signs ⚠️

- Multiple commits per feature
- Stale .ralph/progress.txt
- Failing tests
- Vague commit messages
- Commented-out code

## 🎯 Feature Writing Guide

### Good Features

- ✅ "User can click 'Add' button and see todo form"
- ✅ "API returns 400 for invalid email format"
- ✅ "Navigation highlights active page"

### Bad Features

- ❌ "Implement authentication" (too broad)
- ❌ "Make it look nice" (not testable)
- ❌ "Fix bugs" (not specific)

## 💡 Quick Commands

```bash
# Check remaining features
grep -c '"passes": false' .ralph/prd.json

# View recent progress
tail -50 .ralph/progress.txt

# See what's changed
git diff

# Undo uncommitted changes
git checkout .

# View specific commit
git show HEAD

# Run all checks
npm run typecheck && npm test && npm run lint
```

## ⚙️ Configuration Options

### Core Options

```bash
# Run mode
RUN_MODE=once              # Default: one iteration then stop
RUN_MODE=continuous        # Run until complete or max iterations

# Max iterations (continuous mode only)
MAX_ITERATIONS=100         # Default: 100

# AI agent mode
AI_AGENT_MODE=claude       # Default: use Claude API
AI_AGENT_MODE=manual       # Manual: interactive prompts
```

### Git Safety

```bash
# Protected branches (default: main,master)
PROTECTED_BRANCHES="main,master"

# Auto-create feature branches (default: true)
AUTO_CREATE_BRANCH=true

# Allow git push (default: false - safety first!)
ALLOW_GIT_PUSH=false
```

### Quality Gates

```bash
# Auto-fix prettier formatting (default: true)
AUTOFIX_PRETTIER=true

# Rollback on failure (default: true)
ROLLBACK_ON_FAILURE=true

# Verify before complete (default: true)
VERIFY_BEFORE_COMPLETE=true

# Test output mode (default: failures)
TEST_OUTPUT_MODE=failures  # Show only failing tests
TEST_OUTPUT_MODE=summary   # Show only stats
TEST_OUTPUT_MODE=full      # Show everything
```

### Logging and Display

```bash
# Log level (default: INFO)
LOG_LEVEL=DEBUG            # Most verbose
LOG_LEVEL=INFO             # Normal (default)
LOG_LEVEL=WARN             # Warnings + errors only
LOG_LEVEL=ERROR            # Errors only

# Persistent logging
LOG_FILE=".ralph/ralph.log"

# Progress header (default: true)
SHOW_PROGRESS_HEADER=true

# QA agent second pass after developer commit (default: true)
ENABLE_QA_AGENT=true
# Disable QA agent to preserve single-agent behavior
ENABLE_QA_AGENT=false
# Custom QA prompt file (default: QA_AGENT_PROMPT.md)
QA_AGENT_PROMPT_FILE="QA_AGENT_PROMPT.md"
# Custom QA knowledge file (default: .ralph/qa-knowledge.md)
QA_KNOWLEDGE_FILE=".ralph/qa-knowledge.md"
```

### Advanced Options

```bash
# PRD storage mode (default: file)
PRD_STORAGE=file           # Use local .ralph/prd.json
PRD_STORAGE=sanity         # Use Sanity CMS (requires config)

# Custom PRD file path
PRD_FILE=".ralph/prd.json"

# Custom progress file path
PROGRESS_FILE=".ralph/progress.txt"

# Sanity configuration (when PRD_STORAGE=sanity)
SANITY_PROJECT_ID="your-project-id"
SANITY_DATASET="production"
SANITY_TOKEN="your-write-token"
```

### Command-Line Flags

```bash
# Help
./ralph.sh --help

# Verbose mode (LOG_LEVEL=DEBUG)
./ralph.sh --verbose

# Quiet mode (LOG_LEVEL=ERROR)
./ralph.sh --quiet

# Health check
./ralph.sh --doctor

# Custom branch name (auto-creation)
./ralph.sh --branch-name my-custom-branch
```

## 📋 PRD Schema v2.0

```json
{
  "project": "Project Name",
  "description": "Project description",
  "schema_version": "2.0",
  "features": [
    {
      "id": "001",
      "type": "feature",              // feature|bug|refactor|test|spike
      "category": "functional",       // setup|infrastructure|functional|testing|quality|documentation
      "priority": "critical",         // critical|high|medium|low
      "description": "Feature description",
      "estimated_complexity": "small", // small|medium|large
      "depends_on": [],               // Array of feature IDs
      "passes": false,                // true when complete
      "iterations_taken": 0,          // Auto-tracked
      "blocked_reason": null,         // Explanation if blocked
      "test_files": [                 // Optional: required test files
        "tests/my-feature.test.js"
      ],
      "acceptance_criteria": {        // Optional: structured testing
        "unit_tests": ["tests/unit/foo.test.js"],
        "e2e_tests": ["tests/e2e/bar.test.js"],
        "manual_checks": ["Verify UI displays correctly"]
      }
    }
  ]
}
```

**Field Meanings:**
- **type**: `feature` (new), `bug` (fix), `refactor` (improve), `test` (add tests), `spike` (research)
- **category**: `setup`, `infrastructure`, `functional`, `testing`, `quality`, `documentation`
- **priority**: `critical`, `high`, `medium`, `low`
- **estimated_complexity**: `small` (<1hr), `medium` (1-3hrs), `large` (>3hrs)
- **depends_on**: Feature IDs that must be complete first
- **test_files**: Optional array of test files to verify exist
- **acceptance_criteria**: Optional structured testing requirements

## 📱 One-Line Summary Per Step

1. **Get bearings**: Read .ralph/progress.txt, git log, .ralph/prd.json
2. **Start env**: `./.ralph/init.sh`
3. **Test existing**: Verify nothing broke
4. **Select feature**: ONE with `"passes": false`
5. **Implement**: Clean, documented code
6. **Test**: Browser automation + unit tests + type check
7. **Update PRD**: Change `passes` to `true` only if verified
8. **Log**: Append to .ralph/progress.txt
9. **Commit**: `git commit -m "feat: ..."`
10. **Check done**: If all pass, say `PROMISE COMPLETE`

---

**Remember**: Small, verified steps lead to robust applications. 🎯
