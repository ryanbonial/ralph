# Ralph Wiggum Troubleshooting Guide

This guide helps you diagnose and fix common issues with the Ralph Wiggum Technique.

## Quick Health Check

Run the doctor command to verify your setup:

```bash
./ralph.sh --doctor
```

This will check:
- ✅ Required tools (git, python3, curl)
- ✅ Git repository setup
- ✅ .ralph directory structure
- ✅ PRD file validity
- ✅ Configuration settings
- ✅ Sanity connection (if using)
- ✅ Quality gates (linting, tests, etc.)

## Common Issues and Solutions

### 1. Missing Required Tools

**Error:**
```
[ERROR] ✗ python3 is not installed or not in PATH
[INFO]   Install with: brew install python3 (macOS) or apt-get install python3 (Linux)
```

**Solution:**
Install the missing tool using your package manager:

**macOS (Homebrew):**
```bash
brew install git python3 curl
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install git python3 curl
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install git python3 curl
```

### 2. Protected Branch Error

**Error:**
```
[ERROR] You are on a protected branch: main
```

**Solution:**

Ralph automatically creates a feature branch if `AUTO_CREATE_BRANCH=true` (default). If you see this error:

1. **Let Ralph create a branch automatically:**
   ```bash
   ./ralph.sh  # Will auto-create branch based on next feature
   ```

2. **Specify a custom branch name:**
   ```bash
   ./ralph.sh --branch-name my-feature-branch
   ```

3. **Create branch manually:**
   ```bash
   git checkout -b feature/my-feature
   ./ralph.sh
   ```

### 3. PRD File Not Found

**Error:**
```
[ERROR] PRD file not found: .ralph/prd.json
```

**Solution:**

You need to initialize the Ralph project first:

1. **Create .ralph directory:**
   ```bash
   mkdir -p .ralph
   ```

2. **Copy PRD template:**
   ```bash
   cp prd.json.template .ralph/prd.json
   ```

3. **Or run the initializer agent** to generate a custom PRD based on your project

### 4. Invalid JSON in PRD

**Error:**
```
[ERROR] PRD file is not valid JSON
```

**Solution:**

Validate and fix your PRD JSON:

1. **Check syntax:**
   ```bash
   python3 -m json.tool .ralph/prd.json
   ```

2. **Common JSON errors:**
   - Missing commas between objects
   - Trailing comma after last item
   - Unquoted keys or values
   - Unescaped quotes in strings

3. **Use a JSON validator:**
   - VS Code: Install "JSON" extension
   - Online: https://jsonlint.com/

### 5. Agent Prompt File Missing

**Error:**
```
[ERROR] Agent prompt file not found: AGENT_PROMPT.md
```

**Solution:**

The AGENT_PROMPT.md file should be in your project root:

```bash
# Check if file exists
ls -la AGENT_PROMPT.md

# If missing, you may need to get it from the Ralph repository
curl -O https://raw.githubusercontent.com/your-repo/ralph/main/AGENT_PROMPT.md
```

### 6. Quality Gate Failures

**Error:**
```
[ERROR] ❌ Quality Gate 2/5: Linting - FAILED
```

**Solution:**

Fix linting, formatting, or type errors before marking features complete:

1. **Check what failed:**
   ```bash
   npm run lint          # Check linting
   npm run format:check  # Check formatting
   npm run typecheck     # Check types
   npm test              # Run tests
   ```

2. **Auto-fix when possible:**
   ```bash
   npm run lint -- --fix  # Auto-fix lint issues
   npm run format         # Auto-format code (if AUTOFIX_PRETTIER=true)
   ```

3. **Review errors:**
   - Read the error messages carefully
   - Fix the issues in your code
   - Re-run the checks

### 7. Sanity Connection Failures

**Error:**
```
[ERROR] Failed to fetch PRD from Sanity (curl exit code: 22)
[ERROR] Sanity configuration invalid
```

**Solution:**

Check your Sanity configuration:

1. **Verify environment variables:**
   ```bash
   echo $SANITY_PROJECT_ID
   echo $SANITY_DATASET
   echo $SANITY_TOKEN
   ```

2. **Set configuration if missing:**
   ```bash
   export SANITY_PROJECT_ID=your-project-id
   export SANITY_DATASET=production
   export SANITY_TOKEN=your-auth-token
   export PRD_STORAGE=sanity
   ```

3. **Get your Sanity token:**
   - Go to https://sanity.io/manage
   - Select your project
   - Go to API → Tokens
   - Create a token with "Editor" permissions

4. **Test connection:**
   ```bash
   curl -H "Authorization: Bearer $SANITY_TOKEN" \
     "https://${SANITY_PROJECT_ID}.api.sanity.io/v2021-10-21/data/query/${SANITY_DATASET}?query=*[_type=='ralphProject'][0]"
   ```

### 8. Tests Not Running

**Error:**
```
[ERROR] Quality Gate 4/5: Test Suite - No test script found
```

**Solution:**

Ensure tests are configured:

1. **Check package.json has test script:**
   ```json
   {
     "scripts": {
       "test": "jest",  // or your test command
     }
   }
   ```

2. **Install test dependencies:**
   ```bash
   npm install --save-dev jest  # or your testing framework
   ```

3. **Verify tests work:**
   ```bash
   npm test
   ```

### 9. Git Push Blocked

**Error:**
```
[ERROR] Git push detected but ALLOW_GIT_PUSH=false
```

**Solution:**

This is a safety feature. Ralph blocks git push by default:

1. **To enable push (use carefully):**
   ```bash
   ALLOW_GIT_PUSH=true ./ralph.sh
   ```

2. **Better approach: Push manually after reviewing:**
   ```bash
   ./ralph.sh              # Run Ralph locally
   git log -1              # Review the commit
   git push                # Push manually when satisfied
   ```

### 10. Feature Won't Complete (Type: feature or bug)

**Error:**
```
[ERROR] Quality Gate 5/5: Test Coverage - FAILED
[ERROR] Feature type 'feature' requires test files, but no tests found
```

**Solution:**

For `type: "feature"` or `type: "bug"`, you **must** write tests:

1. **For features:**
   - Write tests for the new functionality
   - Add test file paths to `test_files` field in PRD

2. **For bugs:**
   - Follow TDD Red-Green workflow:
     1. Write failing test that reproduces bug
     2. Verify test fails (RED)
     3. Fix the bug
     4. Verify test passes (GREEN)

3. **Update PRD with test files:**
   ```json
   {
     "id": "001",
     "type": "feature",
     "test_files": ["tests/my-feature.test.js"]
   }
   ```

## Verbose Logging for Debugging

Enable verbose output to see detailed logs:

```bash
./ralph.sh --verbose
```

Or:
```bash
LOG_LEVEL=DEBUG ./ralph.sh
```

This shows:
- ✅ Tool availability checks
- 🔍 Internal function calls
- 📝 Configuration values
- 🔧 Detailed error context

## Persistent Logging

Save logs to a file for later review:

```bash
LOG_FILE=".ralph/ralph.log" ./ralph.sh
```

Then review logs:
```bash
tail -f .ralph/ralph.log  # Follow logs in real-time
less .ralph/ralph.log     # Browse logs
```

## Configuration Debugging

Check your configuration:

```bash
./ralph.sh --doctor
```

This displays all configuration values:
- RUN_MODE
- LOG_LEVEL
- AUTO_CREATE_BRANCH
- PROTECTED_BRANCHES
- ALLOW_GIT_PUSH
- ROLLBACK_ON_FAILURE
- TEST_REQUIRED_FOR_FEATURES
- PRD_STORAGE
- And more...

## Still Having Issues?

1. **Run the doctor:**
   ```bash
   ./ralph.sh --doctor
   ```

2. **Enable verbose logging:**
   ```bash
   ./ralph.sh --verbose
   ```

3. **Check the logs:**
   ```bash
   tail -50 .ralph/progress.txt
   ```

4. **Verify git status:**
   ```bash
   git status
   git log --oneline -5
   ```

5. **Check PRD validity:**
   ```bash
   python3 -m json.tool .ralph/prd.json
   ```

6. **Open an issue:**
   - Include: Output from `--doctor`
   - Include: Error messages
   - Include: Your configuration
   - Include: Steps to reproduce

## Getting Help

- **Documentation**: See README.md for full setup instructions
- **Examples**: Check prd.json.template for PRD examples
- **Quick Reference**: See QUICK_REFERENCE.md
- **GitHub Issues**: Report bugs and ask questions

## Prevention Tips

1. **Always run --doctor after setup changes**
2. **Use --verbose when troubleshooting**
3. **Keep your PRD JSON valid (use a JSON linter)**
4. **Write tests for features and bugs (enforced by quality gates)**
5. **Review commits before continuing**: `git log -1 --stat`
6. **Use human-in-the-loop mode initially**: `RUN_MODE=once` (default)
7. **Keep Ralph updated** to get bug fixes and improvements
