# Ralph Wiggum Technique - Complete Implementation Kit

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world."

A complete, ready-to-use system for autonomous, incremental software development using AI agents in a continuous loop.

## 🎯 What Is This?

The Ralph Wiggum Technique enables AI coding agents to build complex applications systematically across multiple sessions/context windows. Instead of trying to build everything at once, the agent works on ONE feature at a time, tests it thoroughly, and leaves clear documentation for the next session.

Based on:

- [Matt Pocock's YouTube video: "Ship working code while you sleep with the Ralph Wiggum technique"](https://www.youtube.com/watch?v=_IK18goX4X8)
- [Anthropic's research on long-running agent harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Geoffrey Huntley's Ralph Wiggum loop pattern](https://ghuntley.com/ralph/)

> **Note:** This is a complete production toolkit for building applications across multiple sessions. If you're looking for the official [Claude Code plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) for in-session loops, that's different—it's great for iterative refinement within a single session. This implementation focuses on **systematic multi-session development** with git integration, structured PRDs, dependency tracking, and safety features.

## 📦 What's Included

This kit contains everything you need:

| File                            | Purpose                                    |
| ------------------------------- | ------------------------------------------ |
| `The Ralph Wiggum Technique.md` | Comprehensive explanation of the technique |
| `AGENT_PROMPT.md`               | **Ready-to-use prompt for coding agents**  |
| `INITIALIZER_PROMPT.md`         | **Prompt for first-time project setup**    |
| `prd.json.template`             | Example feature list structure             |
| `ralph.sh`                      | Bash script to orchestrate the agent loop  |
| `init.sh.template`              | Example development environment script     |
| `README.md`                     | This file - quick start guide              |

## 📁 Using Ralph Across Multiple Projects

Ralph lives in `/code/ralph` as your **toolkit directory**. To use it in other projects, create a wrapper script:

```bash
# In your project directory (e.g., ~/code/my-project/)
# Create ralph-local.sh
cat > ralph-local.sh << 'EOF'
#!/bin/bash
# Wrapper to run Ralph with correct paths

RALPH_DIR="/Users/ryan.bonial/code/ralph"
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

- Runs `npm run typecheck`, `npm test`, `npm run lint`
- Only accepts commits if all tests pass

**Disable for manual control:**

```bash
ROLLBACK_ON_FAILURE=false VERIFY_BEFORE_COMPLETE=false ./ralph.sh
```

## 📊 Feature Dependencies

Features can now declare dependencies:

```json
{
  "id": "005",
  "description": "User can delete a todo",
  "depends_on": ["001", "003"], // Needs create and display first
  "passes": false
}
```

The agent will automatically skip features with unmet dependencies.

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

## 🎓 Learning Resources

- [Matt Pocock: Ship working code while you sleep (YouTube)](https://www.youtube.com/watch?v=_IK18goX4X8) - Great video introduction to the Ralph technique
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
