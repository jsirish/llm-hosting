# Contributing to llm-hosting

## Git Workflow

We use a **feature branch workflow** with Copilot code review before merging to `main`.

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch (use descriptive names)
git checkout -b feature/add-model-xyz
git checkout -b fix/path-resolution-bug
git checkout -b docs/update-readme
```

**Branch Naming Convention:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `perf/` - Performance improvements

### 2. Make Your Changes

```bash
# Make changes to files
# Test your changes locally and on RunPod

# Stage and commit
git add .
git commit -m "feat: Add support for Model XYZ

- Add model launch script
- Update documentation
- Configure vLLM parameters"
```

**Commit Message Format:**
```
<type>: <short summary>

<detailed description>
<list of changes>
```

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`

### 3. Push to GitHub

```bash
git push origin feature/add-model-xyz
```

### 4. Create Pull Request

1. Go to https://github.com/jsirish/llm-hosting
2. Click "Compare & pull request"
3. Fill out the PR template
4. Add `@copilot` mention to request review
5. Wait for Copilot's review feedback

### 5. Request Copilot Review

In your PR description or comments, mention:
```
@copilot please review this PR for:
- Code quality and best practices
- Security issues (hardcoded secrets, etc.)
- Performance optimizations
- Documentation completeness
```

### 6. Address Review Feedback

```bash
# Make requested changes
git add .
git commit -m "fix: Address review feedback"
git push origin feature/add-model-xyz
```

### 7. Merge to Main

Once approved:
1. Ensure all checks pass
2. Merge the PR (use "Squash and merge" for clean history)
3. Delete the feature branch

```bash
# After merge, update your local main
git checkout main
git pull origin main
git branch -d feature/add-model-xyz
```

## Quick Commands Reference

```bash
# Start new feature
git checkout main && git pull && git checkout -b feature/my-feature

# See what branch you're on
git branch --show-current

# Switch between branches
git checkout main
git checkout feature/my-feature

# Push feature branch
git push origin feature/my-feature

# Update feature branch with latest main
git checkout feature/my-feature
git merge main

# Delete merged branch
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

## Best Practices

1. **Keep branches small and focused** - One feature/fix per branch
2. **Pull main regularly** - Keep your branch up to date
3. **Test before pushing** - Verify changes work locally and on RunPod
4. **Write clear commit messages** - Explain what and why
5. **No secrets in code** - Use environment variables
6. **Update docs** - Keep documentation in sync with code changes
7. **Request Copilot review** - Get automated feedback before merge

## Example Workflow

```bash
# 1. Start new feature
git checkout main
git pull origin main
git checkout -b feature/add-llama-model

# 2. Make changes
# ... edit files ...

# 3. Test
./models/llama.sh  # Test on RunPod

# 4. Commit
git add models/llama.sh docs/
git commit -m "feat: Add Llama 3.1 70B model support

- Add launch script with optimized parameters
- Update model documentation
- Configure 128K context window"

# 5. Push
git push origin feature/add-llama-model

# 6. Create PR on GitHub and request Copilot review

# 7. After approval and merge
git checkout main
git pull origin main
git branch -d feature/add-llama-model
```

## Need Help?

- Check existing PRs for examples
- Review closed PRs to see the workflow
- Ask questions in PR comments
- Mention @copilot for guidance
