# Ralph Wiggum Technique - Quick Reference Card

## 🎯 Core Principle

**ONE feature per iteration. Test thoroughly. Leave clean.**

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
./.ralph/init.sh             # Start dev server
```

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

Only if fully verified:

```json
"passes": false  →  "passes": true
```

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
