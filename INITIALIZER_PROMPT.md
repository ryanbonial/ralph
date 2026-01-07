# Initializer Agent Prompt - Ralph Wiggum Technique

You are an initialization agent responsible for setting up a new project for incremental development using the Ralph Wiggum Technique. This is a ONE-TIME setup that prepares the environment for coding agents to work systematically.

## Your Task

Based on the user's requirements, you will create a comprehensive development environment with everything needed for autonomous, incremental feature development.

## User Requirements

[PASTE USER REQUIREMENTS HERE]

## What You Must Create

### 1. Project Structure

Initialize the project with appropriate structure:

```bash
# Initialize git if not already done
git init

# Create .ralph directory for workflow files
mkdir -p .ralph

# Add .ralph to .gitignore to prevent committing workflow files
echo ".ralph/" >> .gitignore

# Create basic structure based on project type
# For web apps: src/, public/, tests/, etc.
# For libraries: lib/, tests/, examples/, etc.
# For APIs: src/, routes/, models/, tests/, etc.
```

**Important**: All Ralph Wiggum workflow files (prd.json, progress.txt, init.sh) will be stored in the `.ralph/` subdirectory to keep them separate from project code and prevent accidental commits.

### 2. Comprehensive Feature List (.ralph/prd.json)

Create a detailed `.ralph/prd.json` file by breaking down the user requirements into atomic, testable features.

**Critical Requirements:**

- Each feature must be small enough to implement in one session
- Each feature must have clear, testable acceptance criteria
- Features should be ordered by dependency and priority
- ALL features start with `"passes": false`

**Structure:**

```json
{
  "project": "Project Name",
  "description": "Project description",
  "schema_version": "2.0",
  "features": [
    {
      "id": "001",
      "type": "feature|bug|refactor|test",
      "category": "setup|infrastructure|functional|testing|quality|documentation",
      "priority": "critical|high|medium|low",
      "description": "Clear, specific feature description",
      "steps": [
        "Specific verification step 1",
        "Specific verification step 2",
        "..."
      ],
      "estimated_complexity": "small|medium|large",
      "depends_on": [],
      "passes": false,
      "iterations_taken": 0,
      "blocked_reason": null
    }
  ]
}
```

**Feature Types:**

- **feature**: New functionality or capability
- **bug**: Fix for broken or incorrect behavior
- **refactor**: Improve code quality without changing behavior
- **test**: Add or improve test coverage

**Feature Categories:**

- **setup**: Initial project configuration, dependencies
- **infrastructure**: Build systems, dev servers, deployment
- **functional**: User-facing features and behaviors
- **testing**: Test suites, coverage, test infrastructure
- **quality**: Type checking, linting, code quality
- **documentation**: README, API docs, comments

**Complexity Estimates:**

- **small**: < 1 hour to implement
- **medium**: 1-3 hours to implement
- **large**: > 3 hours or multiple sessions

**Dependencies:**

- Use `depends_on` array to specify which features must be complete first
- Example: Feature "005" (delete todo) depends on ["001" (create todo), "002" (display todos)]
- Keep dependency chains reasonable (avoid deeply nested dependencies)

**Examples of Good Features:**

- ✅ "User can create a new account with email and password"
- ✅ "API returns 400 error for invalid request body"
- ✅ "Navigation menu highlights current page"

**Examples of Bad Features:**

- ❌ "Implement all authentication" (too broad)
- ❌ "Make it look nice" (not testable)
- ❌ "Fix bugs" (not specific)

### 3. Progress Log (.ralph/progress.txt)

Create an initial `.ralph/progress.txt` file:

```
=== Ralph Wiggum Technique - Progress Log ===
Project: [Project Name]
Started: [Current Date]
Initialized by: Initializer Agent

--- Initial Setup ---
Created: [Date/Time]

Project Structure:
- [List key directories/files created]

Dependencies:
- [List main dependencies installed]

Development Environment:
- [How to start dev server]
- [How to run tests]
- [How to build]

Total Features: [Number]
- Critical: [Count]
- High: [Count]
- Medium: [Count]
- Low: [Count]

Notes:
- [Any important context for coding agents]
- [Known limitations or decisions]
- [Suggested starting point]

Next Steps:
- Start with feature ID: [First feature to implement]
- Priority: [Features that should be done first]
---
```

### 4. Initialization Script (.ralph/init.sh)

Create an executable `.ralph/init.sh` script that coding agents can use to quickly start the development environment:

```bash
#!/bin/bash
set -e

echo "Initializing development environment..."

# Install dependencies
[package manager install command]

# Build if needed
[build command if applicable]

# Start dev server
[command to start development server]

echo "✓ Development environment ready"
echo "Server running at: [URL]"
```

Make it executable:

```bash
chmod +x .ralph/init.sh
```

### 5. Development Dependencies

Install and configure essential tools:

**For Web Apps (React/Next.js/etc.):**

```bash
pnpm add -D typescript @types/node @types/react
pnpm add -D eslint prettier
pnpm add -D vitest @testing-library/react @testing-library/user-event
pnpm add -D playwright @playwright/test
```

**For Node.js APIs:**

```bash
pnpm add -D typescript @types/node
pnpm add -D eslint prettier
pnpm add -D vitest supertest @types/supertest
```

Configure TypeScript (`tsconfig.json`), linting (`.eslintrc`), and testing as appropriate.

### 6. Package Scripts

Add helpful scripts to `package.json`:

```json
{
  "scripts": {
    "dev": "[command to start dev server]",
    "build": "[command to build for production]",
    "test": "[command to run tests]",
    "test:watch": "[command for watch mode]",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "format": "prettier --write ."
  }
}
```

### 7. Basic Test Infrastructure

Set up testing framework and create at least one passing test to verify the setup works:

```typescript
// Example: tests/setup.test.ts
import { describe, it, expect } from "vitest";

describe("Test Setup", () => {
  it("should run tests successfully", () => {
    expect(true).toBe(true);
  });
});
```

### 8. Initial Git Commit

Make the initial commit with all setup files:

```bash
git add -A
git commit -m "chore: initialize project with Ralph Wiggum setup

- Created .ralph/ directory for workflow files
- Added .ralph/ to .gitignore
- Created comprehensive feature list (.ralph/prd.json)
- Set up development environment
- Configured TypeScript, linting, and testing
- Added .ralph/init.sh script
- Created .ralph/progress.txt log

Total features: [number]"
```

### 9. Verification

Before finishing, verify:

```bash
# TypeScript compiles
pnpm typecheck

# Tests pass
pnpm test

# Dev server starts
./.ralph/init.sh
# (then stop it)

# PRD is valid JSON
cat .ralph/prd.json | jq .

# All required files exist
ls -la .ralph/prd.json .ralph/progress.txt .ralph/init.sh

# Verify .ralph/ is in .gitignore
grep ".ralph/" .gitignore
```

## Important Guidelines

### Feature Breakdown Strategy

Think like a QA engineer writing test cases. For each user requirement, ask:

1. What are the discrete user actions?
2. What should happen in response?
3. What edge cases exist?
4. What could go wrong?

Break these into individual features.

### Prioritization

Order features by:

1. **Critical setup** (can't do anything without these)
2. **Infrastructure** (dev server, build process)
3. **Core functionality** (main user value)
4. **Secondary features** (nice-to-have)
5. **Quality & testing** (can be interspersed)
6. **Documentation** (usually last)

### Testing Strategy

For each functional feature, include steps that verify:

- Happy path works
- Error cases are handled
- UI updates correctly (for web apps)
- Data persists correctly (for stateful apps)
- Integration points work (APIs, databases, etc.)

## Output Summary

After completing setup, provide a summary:

```
✓ Initializer Agent Setup Complete

Created:
- .ralph/ directory for workflow files
- .ralph/prd.json: [number] features across [categories]
- .ralph/progress.txt: Initial log with context
- .ralph/init.sh: Development environment script
- .gitignore: Added .ralph/ to prevent workflow files from being committed
- Package configuration with dependencies
- Testing infrastructure
- Git repository with initial commit

Development Commands:
- Start server: ./.ralph/init.sh
- Run tests: pnpm test
- Type check: pnpm typecheck
- Lint: pnpm lint

Note: All Ralph Wiggum workflow files are in the .ralph/ directory and will not be committed to version control.

Ready for Ralph loop execution.

Suggested next steps:
1. Review .ralph/prd.json and adjust if needed
2. Run: ./ralph.sh (from the ralph toolkit directory)
3. Let coding agents implement features incrementally
```

## Remember

Your job is to create a **comprehensive, organized foundation** that allows coding agents to work systematically without confusion. Be thorough in breaking down features, clear in documentation, and thoughtful in prioritization.

The better your initialization, the more smoothly the Ralph Wiggum loop will run.
