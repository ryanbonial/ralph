# Getting Started with Ralph Wiggum Technique

## 📚 Which File Do I Use?

```
┌─────────────────────────────────────────────────────┐
│                  STARTING NEW PROJECT?              │
└─────────────────────────────────────────────────────┘
                          │
                          ↓
              ┌───────────────────────┐
              │ INITIALIZER_PROMPT.md │ ← Give this to your AI agent
              └───────────────────────┘    with your project requirements
                          │
                          ↓
         ┌────────────────────────────────┐
         │ Agent creates:                 │
         │ • .ralph/ directory            │
         │ • .ralph/prd.json              │
         │ • .ralph/progress.txt          │
         │ • .ralph/init.sh               │
         │ • .gitignore (with .ralph/)    │
         │ • Project structure            │
         └────────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────┐
│              IMPLEMENTING FEATURES?                  │
└─────────────────────────────────────────────────────┘
                          │
                          ↓
              ┌───────────────────────┐
              │   AGENT_PROMPT.md     │ ← Give this to your AI agent
              └───────────────────────┘    for each iteration
                          │
                          ↓
         Agent implements ONE feature,
         tests it, commits, repeats...
                          │
                          ↓
              ┌───────────────────────┐
              │   PROMISE COMPLETE    │
              └───────────────────────┘
```

## 🎯 Three Simple Steps

### Step 1: Initialize (First Time Only)

**What you need:**

- Your project requirements (text description)
- `INITIALIZER_PROMPT.md`

**What to do:**

1. Open your AI coding agent (Cursor, Claude, etc.)
2. Give it this instruction:

   ```
   I want to use the Ralph Wiggum Technique.

   My project requirements:
   [PASTE YOUR REQUIREMENTS HERE]

   Please read and follow: INITIALIZER_PROMPT.md
   ```

3. Let the agent create all the necessary files

**What you'll get:**

- `.ralph/` directory (gitignored)
- `.ralph/prd.json` - Complete feature list
- `.ralph/progress.txt` - Progress log
- `.ralph/init.sh` - Dev environment script
- Full project structure with dependencies

### Step 2: Implement Features (Repeat Until Done)

**What you need:**

- The files created in Step 1
- `AGENT_PROMPT.md`

**What to do:**

**Option A: Human-in-the-Loop (Recommended for learning)**

1. Run: `./ralph.sh`
2. Agent implements ONE feature
3. Review the changes
4. Run again: `./ralph.sh`
5. Repeat

**Option B: Continuous AFK Mode**

1. Run: `RUN_MODE=continuous ./ralph.sh`
2. Agent runs until all features complete
3. Great for overnight runs

**Option C: Interactive Manual Control**

1. Open your AI coding agent
2. Give it: `AGENT_PROMPT.md`
3. Let it implement ONE feature
4. Review and repeat

**What happens:**

- Agent reads .ralph/progress.txt and .ralph/prd.json
- Implements one feature
- Tests thoroughly
- Updates .ralph/prd.json and .ralph/progress.txt
- Makes git commit
- Repeats

### Step 3: Completion

When all features are done, agent outputs:

```
PROMISE COMPLETE
```

Your project is finished! 🎉

## 📖 Example Walkthrough

### Example: Building a Todo App

**1. Create requirements.txt:**

```
Todo List Web Application

Features needed:
- User can add a new todo item
- User can mark todo as complete
- User can delete a todo
- User can filter by All/Active/Completed
- Todos persist in local storage
- Responsive design for mobile
- Dark mode toggle
```

**2. Give to initializer agent:**

```
I want to build this using the Ralph Wiggum Technique.

Requirements: [paste requirements.txt]

Please read: INITIALIZER_PROMPT.md
```

**3. Agent creates structure:**

```
project/
├── .ralph/
│   ├── prd.json          (15 features defined)
│   ├── progress.txt      (Initial setup logged)
│   └── init.sh           (Start dev server script)
├── .gitignore            (.ralph/ added)
├── package.json          (Dependencies added)
├── src/
│   ├── App.tsx
│   └── components/
├── tests/
└── README.md
```

**4. Review .ralph/prd.json:**

```json
{
  "features": [
    {
      "id": "001",
      "description": "User can add a new todo item",
      "passes": false
    },
    {
      "id": "002",
      "description": "User can mark todo as complete",
      "passes": false
    }
    // ... 13 more features
  ]
}
```

**5. Start implementation:**

```
Please implement features using: AGENT_PROMPT.md
```

**6. First iteration:**

```
Agent:
1. Reads .ralph/progress.txt and git log
2. Runs ./.ralph/init.sh
3. Tests that dev server works
4. Selects feature 001
5. Implements add todo functionality
6. Tests with browser automation
7. Marks feature 001 as passes: true in .ralph/prd.json
8. Updates .ralph/progress.txt
9. Commits: "feat: add new todo item functionality"
```

**7. Second iteration:**

```
Agent:
1. Reads .ralph/progress.txt (sees feature 001 done)
2. Tests feature 001 still works
3. Selects feature 002
4. Implements mark complete
5. Tests both features work together
6. Marks feature 002 as passes: true in .ralph/prd.json
7. Updates .ralph/progress.txt
8. Commits: "feat: mark todo as complete"
```

**8. Repeat until:**

```
All 15 features implemented and tested
Agent outputs: PROMISE COMPLETE
```

## 🛠️ File Reference

| File                            | When to Use     | Purpose                        |
| ------------------------------- | --------------- | ------------------------------ |
| `README.md`                     | First           | Overview of entire system      |
| `GETTING_STARTED.md`            | First           | This file - step-by-step guide |
| `INITIALIZER_PROMPT.md`         | Once            | Set up new project             |
| `AGENT_PROMPT.md`               | Every iteration | Implement features             |
| `QUICK_REFERENCE.md`            | Anytime         | Quick lookup for agent         |
| `The Ralph Wiggum Technique.md` | Reference       | Detailed explanation           |
| `prd.json.template`             | Reference       | Example feature list format    |
| `init.sh.template`              | Reference       | Example dev script             |
| `ralph.sh`                      | Optional        | Automated loop orchestration   |

## 📋 Cheat Sheet

### For New Projects

```bash
# 1. Create your requirements
vim requirements.txt

# 2. Give INITIALIZER_PROMPT.md to agent with requirements

# 3. After initialization, start coding loop

# Human-in-the-loop (one iteration at a time - RECOMMENDED)
./ralph.sh

# Continuous AFK mode (runs until complete)
RUN_MODE=continuous ./ralph.sh

# Manual control (give AGENT_PROMPT.md to agent repeatedly)
# (if you prefer interactive control)
```

### For Existing Projects

```bash
# 1. Create .ralph directory
mkdir -p .ralph
echo ".ralph/" >> .gitignore

# 2. Create prd.json manually
cp prd.json.template .ralph/prd.json
# Edit .ralph/prd.json with your features

# 3. Create progress log
echo "=== Progress Log ===" > .ralph/progress.txt

# 4. Initialize git
git init && git add . && git commit -m "Initial commit"

# 5. Start coding loop
# Give AGENT_PROMPT.md to agent
```

### Checking Progress

```bash
# How many features left?
grep -c '"passes": false' .ralph/prd.json

# What was done recently?
tail -50 .ralph/progress.txt

# What's the latest commit?
git log -1

# View all features
cat .ralph/prd.json | jq '.features[] | {id, description, passes}'
```

## ❓ FAQ

**Q: Can I use this with GPT-4, Claude, or other models?**
A: Yes! The prompts work with any capable coding agent.

**Q: Does this work for non-web projects?**
A: Yes! Works for APIs, CLIs, libraries, etc. Adjust testing strategy.

**Q: What if a feature is too big?**
A: Break it down into smaller features in `.ralph/prd.json`.

**Q: Can I modify features during development?**
A: Yes, but only add new ones or update descriptions. Don't delete.

**Q: Will my Ralph files get committed to git?**
A: No, the `.ralph/` directory is automatically added to `.gitignore` by the initializer.

**Q: How long does a typical feature take?**
A: 5-15 minutes for the agent. Keep features atomic.

**Q: What if the agent gets stuck?**
A: It will document the blocker and move to another feature.

**Q: Do I need to review every iteration?**
A: Use human-in-the-loop mode (`./ralph.sh`) to review each iteration. Once confident, switch to continuous mode (`RUN_MODE=continuous ./ralph.sh`).

**Q: Can multiple agents work together?**
A: Yes! Each reads the same .ralph/progress.txt and .ralph/prd.json.

## 🎓 Next Steps

1. **Read**: `README.md` for full overview
2. **Initialize**: Use `INITIALIZER_PROMPT.md` for your project
3. **Implement**: Give agent `AGENT_PROMPT.md` repeatedly
4. **Reference**: Keep `QUICK_REFERENCE.md` handy
5. **Learn**: Read `The Ralph Wiggum Technique.md` for deep dive

## 🚀 Ready to Start?

Pick one:

### Option 1: Try with Example Project

```bash
# Create a simple example
echo "Build a simple calculator web app" > requirements.txt
# Give INITIALIZER_PROMPT.md + requirements to agent
```

### Option 2: Your Real Project

```bash
# Write your actual requirements
vim my-project-requirements.txt
# Give INITIALIZER_PROMPT.md + requirements to agent
```

**Happy building!** 🎯
