# Cursor Planning Mode → Ralph PRD Workflow

This guide explains how to use **Cursor Planning Mode** for architecture and design, then convert that plan into a **Ralph-compatible PRD** for automated execution.

## The Two-Phase Approach

### Phase 1: Planning Mode (Architecture & Design)
Use Cursor Planning Mode to:
- Design high-level architecture
- Break down complex features into logical steps
- Identify dependencies and risks
- Make architectural decisions
- Create implementation roadmap

### Phase 2: Ralph Mode (Execution)
Use Ralph to:
- Execute features incrementally, one at a time
- Make verifiable progress with git commits
- Track feature completion and dependencies
- Ensure quality through automated tests and gates

## Why This Workflow?

| Aspect | Planning Mode | Ralph Mode |
|--------|---------------|------------|
| **Purpose** | Think, design, architect | Execute, implement, verify |
| **Scope** | Entire project or epic | Single feature at a time |
| **Output** | Plans, diagrams, decisions | Working code, tests, commits |
| **Context** | Full project context | Fresh context per feature |
| **Best For** | Strategy, architecture | Tactical implementation |

**Key Insight:** Planning Mode helps you decide *what* to build and *how* to structure it. Ralph helps you actually *build it* incrementally with verification at each step.

## Step-by-Step Workflow

### Step 1: Use Planning Mode to Create Feature List

In Cursor, enter Planning Mode and use this prompt template:

```
I need help planning the implementation of [PROJECT DESCRIPTION].

Please break this down into a list of features following this structure:

For each feature, provide:
- id: A unique 3-digit number (001, 002, etc.) or letter suffix (000a, 001b)
- type: One of "feature" (new functionality), "bug" (fix), "refactor" (improve code), "test" (add tests), "spike" (exploration)
- category: One of "setup", "infrastructure", "functional", "testing", "quality", "documentation"
- priority: One of "critical", "high", "medium", "low"
- description: Clear 1-sentence description (10-200 characters)
- steps: Array of 5-10 concrete implementation steps
- estimated_complexity: One of "small" (<1hr), "medium" (1-3hrs), "large" (>3hrs)
- depends_on: Array of feature IDs that must be completed first (use [] if none)
- test_files: (Optional) Array of test file paths expected for this feature

Please also:
- Identify the logical order of implementation
- Note which features can be done in parallel (no dependencies)
- Flag any features that are particularly risky or complex
- Suggest what should be done first vs. later

Output the features in a format that's easy to convert to JSON for Ralph.
```

### Step 2: Convert Planning Output to PRD JSON

Take the Planning Mode output and structure it as a Ralph PRD. Use the `.ralph/prd.json.template` as a reference.

**Manual Conversion:**
1. Copy `.ralph/prd.json.template` to `.ralph/prd.json`
2. Update `project` and `description` fields
3. Replace the example features with your planned features
4. Ensure all required fields are present
5. Validate JSON syntax

**Example Planning Output:**
```
Feature 001: Set up authentication system
- Type: feature
- Priority: high
- Complexity: large
- Steps:
  1. Add JWT library dependency
  2. Create auth middleware
  3. Implement login endpoint
  4. Implement registration endpoint
  5. Add password hashing
  6. Create auth tests
- Dependencies: None
```

**Converted to PRD JSON:**
```json
{
  "id": "001",
  "type": "feature",
  "category": "infrastructure",
  "priority": "high",
  "description": "Set up authentication system with JWT tokens",
  "steps": [
    "Add JWT library dependency (jsonwebtoken, bcrypt)",
    "Create auth middleware to verify tokens",
    "Implement POST /api/login endpoint",
    "Implement POST /api/register endpoint with validation",
    "Add password hashing with bcrypt (salt rounds: 10)",
    "Create auth integration tests for login/register flows"
  ],
  "estimated_complexity": "large",
  "depends_on": [],
  "passes": false,
  "iterations_taken": 0,
  "blocked_reason": null,
  "test_files": [
    "tests/auth.test.js"
  ]
}
```

### Step 3: Validate the PRD

**Check your PRD has:**
- ✅ Valid JSON syntax (use `python3 -m json.tool .ralph/prd.json` to validate)
- ✅ All required fields: id, type, category, priority, description, steps, estimated_complexity, depends_on, passes, iterations_taken, blocked_reason
- ✅ Logical dependency chains (no circular dependencies)
- ✅ Features in rough priority order
- ✅ Realistic complexity estimates
- ✅ Concrete, actionable steps (not vague)

**Validation script:**
```bash
# Validate JSON syntax
python3 -m json.tool .ralph/prd.json > /dev/null && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

# Check required fields (basic check)
grep -q '"id"' .ralph/prd.json && \
grep -q '"type"' .ralph/prd.json && \
grep -q '"priority"' .ralph/prd.json && \
echo "✅ Has required fields" || echo "❌ Missing required fields"

# Run Ralph doctor to verify setup
./ralph.sh --doctor
```

### Step 4: Run Ralph

Once your PRD is ready, start Ralph:

```bash
# Human-in-the-loop mode (recommended for first few features)
./ralph.sh

# Review the feature, approve the work, see results
# Repeat for each feature

# Later, switch to continuous mode (after you trust the workflow)
RUN_MODE=continuous MAX_ITERATIONS=10 ./ralph.sh
```

## Best Practices

### Granularity

**Good Feature Size:**
- ✅ Can be completed in 1-2 Ralph iterations
- ✅ Has clear acceptance criteria
- ✅ Can be tested independently
- ✅ Produces a single, focused commit

**Too Large:**
- ❌ "Build entire frontend"
- ❌ "Implement all API endpoints"
- ❌ More than 10 implementation steps

**Too Small:**
- ❌ "Add a console.log"
- ❌ "Fix typo" (unless part of quality sweep)
- ❌ Less than 3 implementation steps

**Just Right:**
- ✅ "Add user authentication with JWT"
- ✅ "Implement dashboard with real-time updates"
- ✅ "Create product listing page with filters"

### Dependencies

**Clear Dependencies:**
```json
{
  "id": "002",
  "description": "Add user profile page",
  "depends_on": ["001"],  // Must complete auth first
  ...
}
```

**Parallel Work (No Dependencies):**
```json
{
  "id": "010",
  "description": "Add logging infrastructure",
  "depends_on": [],  // Can do anytime
  ...
},
{
  "id": "011",
  "description": "Implement dark mode",
  "depends_on": [],  // Independent of logging
  ...
}
```

### Complexity Estimation

Use these guidelines:

**Small (<1 hour):**
- Configuration changes
- Simple UI components
- Documentation updates
- Minor bug fixes

**Medium (1-3 hours):**
- New API endpoints with tests
- Complex UI components with state
- Integration of third-party libraries
- Refactoring multiple files

**Large (>3 hours):**
- Authentication systems
- Real-time features (WebSockets, SSE)
- Complex state management
- Multi-step integration flows

### Test Files

**Always specify test_files for features:**
```json
{
  "id": "003",
  "type": "feature",
  "description": "Add shopping cart functionality",
  "test_files": [
    "tests/cart.test.js",
    "tests/cart-integration.test.js"
  ],
  ...
}
```

**Or use acceptance_criteria for structured testing:**
```json
{
  "id": "003",
  "type": "feature",
  "description": "Add shopping cart functionality",
  "acceptance_criteria": {
    "unit_tests": ["tests/cart.test.js"],
    "e2e_tests": ["tests/cart-e2e.test.js"],
    "manual_checks": [
      "Add item to cart and verify count updates",
      "Remove item and verify cart recalculates",
      "Test cart persistence across page reloads"
    ]
  },
  ...
}
```

## Example: Full Workflow

### Planning Phase

```
User asks Planning Mode:
"I need to build a blog with authentication, posts, and comments. Help me plan this."

Planning Mode responds:
"Let me break this into incremental features:

Foundation (Do First):
- 001: Project setup (Next.js, DB, folder structure)
- 002: Authentication system (JWT, login/register)
- 003: Database models (User, Post, Comment schemas)

Core Features:
- 004: Post creation and editing (depends on 002, 003)
- 005: Post listing and detail pages (depends on 003, 004)
- 006: Comment system (depends on 002, 005)

Polish:
- 007: User profiles (depends on 002)
- 008: Post search and filtering (depends on 005)
- 009: UI polish and responsive design

Each feature should take 1-3 hours. Start with 001-003 in sequence,
then 004-006, then 007-009 can be done in any order."
```

### Conversion Phase

Convert to `.ralph/prd.json`:
```json
{
  "project": "Blog with Authentication",
  "description": "Full-featured blog with user auth, posts, and comments",
  "schema_version": "2.0",
  "features": [
    {
      "id": "001",
      "type": "feature",
      "category": "setup",
      "priority": "critical",
      "description": "Set up Next.js project with database and folder structure",
      "steps": [
        "Initialize Next.js project with TypeScript",
        "Set up Prisma with PostgreSQL",
        "Create folder structure: /app, /components, /lib",
        "Add environment variables template (.env.example)",
        "Configure eslint and prettier",
        "Add basic README with setup instructions",
        "Verify dev server runs: npm run dev"
      ],
      "estimated_complexity": "small",
      "depends_on": [],
      "passes": false,
      "iterations_taken": 0,
      "blocked_reason": null
    },
    {
      "id": "002",
      "type": "feature",
      "category": "infrastructure",
      "priority": "critical",
      "description": "Implement authentication system with JWT tokens",
      "steps": [
        "Add dependencies: jsonwebtoken, bcrypt",
        "Create User model in Prisma schema",
        "Implement auth middleware to verify JWT tokens",
        "Create POST /api/auth/register endpoint",
        "Create POST /api/auth/login endpoint",
        "Add session management with cookies",
        "Write auth integration tests"
      ],
      "estimated_complexity": "large",
      "depends_on": ["001"],
      "passes": false,
      "iterations_taken": 0,
      "blocked_reason": null,
      "test_files": [
        "tests/auth.test.ts",
        "tests/auth-integration.test.ts"
      ]
    }
    // ... more features
  ]
}
```

### Execution Phase

```bash
# Validate PRD
python3 -m json.tool .ralph/prd.json > /dev/null && echo "✅ Valid PRD"

# Run Ralph in human-in-the-loop mode
./ralph.sh

# Ralph executes Feature 001
# Agent creates project structure, sets up Next.js, etc.
# Commits: "feat: set up Next.js project with database and folder structure"

# Run Ralph again for Feature 002
./ralph.sh

# Agent implements authentication
# Commits: "feat: implement authentication system with JWT tokens"

# Continue until all features complete
# When done, Ralph outputs: "PROMISE COMPLETE"
```

## Tips for Success

### 1. **Start Small**
Begin with a simple project (3-5 features) to learn the workflow before tackling larger projects.

### 2. **Use Human-in-the-Loop Initially**
Don't jump straight to continuous mode. Watch Ralph work on 3-5 features first to understand the patterns.

### 3. **Be Specific in Steps**
Vague steps like "implement the feature" won't help Ralph. Be concrete:
- ❌ "Add authentication"
- ✅ "Create POST /api/login endpoint with email/password validation"

### 4. **Group Related Features**
Keep related work together with clear dependencies:
```json
// Authentication group
{"id": "001", "description": "Set up auth infrastructure"},
{"id": "002", "description": "Add login UI", "depends_on": ["001"]},
{"id": "003", "description": "Add registration UI", "depends_on": ["001"]},

// Posts group
{"id": "010", "description": "Create post model and API"},
{"id": "011", "description": "Add post creation UI", "depends_on": ["010"]},
```

### 5. **Plan for Testing**
Always include test files or acceptance criteria. Ralph enforces test creation for features:
```json
{
  "type": "feature",
  "test_files": ["tests/feature.test.js"],
  // or
  "acceptance_criteria": {
    "unit_tests": ["tests/unit.test.js"],
    "e2e_tests": ["tests/e2e.test.js"],
    "manual_checks": ["Verify X works", "Test Y scenario"]
  }
}
```

### 6. **Update PRD as You Learn**
As Ralph works, you may discover:
- Features need to be split (too complex)
- Dependencies you missed
- New features needed

It's OK to update the PRD between iterations. Just don't delete features Ralph has already completed.

## Common Pitfalls

### ❌ Planning Too Much Detail
**Problem:** Planning Mode generates 50+ micro-features
**Solution:** Ask for high-level features (10-20), let Ralph figure out implementation details

### ❌ Skipping Dependencies
**Problem:** Feature fails because prerequisite wasn't done
**Solution:** Review dependency chains carefully, use `depends_on` liberally

### ❌ Vague Descriptions
**Problem:** Ralph doesn't know what to build
**Solution:** Be specific in descriptions and steps. Include examples.

### ❌ No Test Strategy
**Problem:** Features complete without tests, bugs appear later
**Solution:** Always include `test_files` or `acceptance_criteria`

### ❌ Too Optimistic Complexity
**Problem:** "small" feature takes 5 hours
**Solution:** When in doubt, estimate higher. Ralph tracks actual time.

## Troubleshooting

### "Ralph keeps getting stuck on a feature"
- **Check if the feature is too large** → Split into smaller features
- **Check if dependencies are met** → Review `depends_on` and mark prerequisites complete
- **Check if steps are clear** → Add more specific implementation steps

### "Planning Mode output doesn't match Ralph schema"
- **Use the prompt template above** → It's designed for Ralph compatibility
- **Manually adjust the output** → Planning Mode is for ideas, you refine into PRD

### "Features are in wrong order"
- **Review dependency chains** → Ensure prerequisites come first
- **Use priority field** → Critical features should be done early
- **Check for circular dependencies** → Feature A depends on B, B depends on A (impossible)

## Advanced: Automatic Conversion Script

For teams that use this workflow frequently, consider creating a script to help convert planning output to PRD:

```bash
#!/bin/bash
# convert-plan-to-prd.sh
# Usage: ./convert-plan-to-prd.sh planning-output.txt

# This is a starter template - customize for your needs
echo "Converting planning output to PRD format..."

# TODO: Parse planning text
# TODO: Extract features, priorities, dependencies
# TODO: Generate JSON structure
# TODO: Validate against schema

echo "Manual refinement needed. Review .ralph/prd.json before running Ralph."
```

## Next Steps

1. ✅ Read this guide
2. ✅ Try Planning Mode with the prompt template
3. ✅ Create your first PRD (start small: 3-5 features)
4. ✅ Validate PRD: `./ralph.sh --doctor`
5. ✅ Run Ralph: `./ralph.sh`
6. ✅ Watch Ralph complete first feature
7. ✅ Iterate until project complete

## Resources

- **PRD Template:** `.ralph/prd.json.template`
- **Ralph Docs:** `README.md`
- **Schema Reference:** `INITIALIZER_PROMPT.md`
- **Agent Instructions:** `AGENT_PROMPT.md`

## Summary

**Planning Mode** (Architecture):**
- Think big picture
- Design system architecture
- Break down into features
- Identify dependencies
- Make decisions

**Ralph Mode** (Execution):
- Execute one feature at a time
- Write code, tests, documentation
- Make commits with verification
- Track progress automatically
- Ensure quality gates pass

**Together:** Plan smart, execute incrementally, ship confidently.
