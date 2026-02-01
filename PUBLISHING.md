# Publishing Guide for @appollo-ui/sf-plugin-deploy-hooks

This guide walks you through publishing the plugin to npm and GitHub.

## Prerequisites

- npm account with access to `@appollo-ui` organization
- GitHub account with access to create repositories under `appollo-ui` organization
- Git installed and configured
- npm CLI installed

## Step 1: Set Up npm Organization

### 1.1 Create npm Account (if needed)
```bash
# Go to https://www.npmjs.com/signup and create an account
# Or login if you already have one
npm login
```

### 1.2 Create or Join Organization
```bash
# Option A: Create the organization at https://www.npmjs.com/org/create
# Organization name: appollo-ui

# Option B: If organization exists, ask admin to add you as a member
```

### 1.3 Verify Access
```bash
npm org ls appollo-ui
# You should see yourself listed as a member
```

## Step 2: Prepare the Package

### 2.1 Verify Package Configuration
```bash
# Check that package.json has correct name
cat package.json | grep '"name"'
# Should show: "name": "@appollo-ui/sf-plugin-deploy-hooks"
```

### 2.2 Build the Package
```bash
npm run clean
npm run build
```

### 2.3 Test Package Locally
```bash
# Create a test tarball
npm pack

# This creates: appollo-ui-sf-plugin-deploy-hooks-2.0.0.tgz
# Test install it:
sf plugins install ./appollo-ui-sf-plugin-deploy-hooks-2.0.0.tgz

# Verify it works
sf plugins

# Clean up test
rm appollo-ui-sf-plugin-deploy-hooks-2.0.0.tgz
sf plugins uninstall @appollo-ui/sf-plugin-deploy-hooks
```

## Step 3: Initialize Git Repository

### 3.1 Initialize Local Git
```bash
cd /Users/matt/Dev/@appollo-ui/sf-plugin-deploy-hooks

git init
git add .
git commit -m "Initial commit: SF CLI Deploy Hooks Plugin v2.0.0

Features:
- Pre and post-deploy hooks
- Deploy result analysis in JSON
- AI-powered error analysis with GitHub Copilot
- Configurable hook execution
- Example scripts for error analysis and notifications"
```

### 3.2 Create GitHub Repository

**Option A: Using GitHub CLI**
```bash
# Login to GitHub (if not already)
gh auth login

# Create the repository
gh repo create appollo-ui/sf-plugin-deploy-hooks \
  --public \
  --description "SF CLI plugin for pre/post-deploy hooks with AI-powered error analysis" \
  --homepage "https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks"
```

**Option B: Using GitHub Web UI**
1. Go to https://github.com/organizations/appollo-ui/repositories/new
   (or create personal repo at https://github.com/new if org doesn't exist)
2. Repository name: `sf-plugin-deploy-hooks`
3. Description: "SF CLI plugin for pre/post-deploy hooks with AI-powered error analysis"
4. Public repository
5. **Do NOT initialize with README** (we already have one)
6. Click "Create repository"

### 3.3 Push to GitHub
```bash
# Add remote (replace with your actual org/user)
git remote add origin https://github.com/appollo-ui/sf-plugin-deploy-hooks.git

# Push code
git branch -M main
git push -u origin main
```

### 3.4 Create Initial Release Tag
```bash
git tag -a v2.0.0 -m "Release v2.0.0

Features:
- Pre and post-deploy hooks
- Deploy result analysis
- AI-powered error analysis
- Example scripts"

git push origin v2.0.0
```

## Step 4: Publish to npm

### 4.1 Ensure You're Logged In
```bash
npm whoami
# Should display your npm username
```

### 4.2 Dry Run (Optional but Recommended)
```bash
npm publish --dry-run

# Review the output to see what files will be published
# Should include: lib/, examples/, README.md, LICENSE, package.json
```

### 4.3 Publish to npm
```bash
# For scoped packages in organizations, use --access public
npm publish --access public
```

You should see output like:
```
npm notice 📦  @appollo-ui/sf-plugin-deploy-hooks@2.0.0
npm notice === Tarball Contents ===
npm notice 1.1kB  LICENSE
npm notice 12.3kB README.md
npm notice 2.1kB  package.json
npm notice 15.2kB lib/...
npm notice 18.5kB examples/...
npm notice === Tarball Details ===
npm notice name:          @appollo-ui/sf-plugin-deploy-hooks
npm notice version:       2.0.0
npm notice package size:  XX.X kB
npm notice unpacked size: XX.X kB
npm notice total files:   XX
npm notice
+ @appollo-ui/sf-plugin-deploy-hooks@2.0.0
```

### 4.4 Verify Publication
```bash
# Check npm
npm view @appollo-ui/sf-plugin-deploy-hooks

# Try installing
sf plugins install @appollo-ui/sf-plugin-deploy-hooks

# Verify
sf plugins

# Test it works
sf project deploy start --dry-run
```

## Step 5: Post-Publication Tasks

### 5.1 Update GitHub Repository

Add topics/tags to the repository:
```bash
gh repo edit appollo-ui/sf-plugin-deploy-hooks \
  --add-topic salesforce \
  --add-topic sf-cli \
  --add-topic sfdx-plugin \
  --add-topic deploy-hooks \
  --add-topic ci-cd \
  --add-topic ai-analysis
```

Or via web UI:
1. Go to https://github.com/appollo-ui/sf-plugin-deploy-hooks
2. Click the gear icon next to "About"
3. Add topics: `salesforce`, `sf-cli`, `sfdx-plugin`, `deploy-hooks`, `ci-cd`, `ai-analysis`

### 5.2 Create GitHub Release

```bash
gh release create v2.0.0 \
  --title "v2.0.0 - Initial Release" \
  --notes "## Features

- ✅ Pre-deploy and post-deploy hooks
- ✅ Deploy result analysis with JSON output
- ✅ AI-powered error analysis using GitHub Copilot CLI
- ✅ Configurable hook execution
- ✅ Example scripts for error analysis and notifications

## Installation

\`\`\`bash
sf plugins install @appollo-ui/sf-plugin-deploy-hooks
\`\`\`

## Documentation

See [README.md](https://github.com/appollo-ui/sf-plugin-deploy-hooks/blob/main/README.md) for full documentation."
```

### 5.3 Announce the Release

Share on:
- Twitter/X with hashtags: #Salesforce #SFDC #SalesforceDev
- LinkedIn
- Salesforce community forums
- Internal team channels

## Future Updates

### Publishing New Versions

1. **Update version in package.json**
   ```bash
   npm version patch  # for bug fixes (2.0.0 → 2.0.1)
   npm version minor  # for new features (2.0.0 → 2.1.0)
   npm version major  # for breaking changes (2.0.0 → 3.0.0)
   ```

2. **Commit and tag**
   ```bash
   git add package.json
   git commit -m "Bump version to x.x.x"
   git tag -a vx.x.x -m "Release vx.x.x"
   git push origin main --tags
   ```

3. **Publish**
   ```bash
   npm run clean
   npm run build
   npm publish --access public
   ```

4. **Create GitHub release**
   ```bash
   gh release create vx.x.x --title "vx.x.x" --notes "Release notes..."
   ```

## Troubleshooting

### "You do not have permission to publish"
```bash
# Ensure you're a member of the @appollo-ui organization
npm org ls appollo-ui

# If not, contact the organization admin
```

### "Package name already exists"
```bash
# Check if package exists
npm view @appollo-ui/sf-plugin-deploy-hooks

# If someone else owns it, you'll need to:
# 1. Use a different package name
# 2. Contact npm support to transfer ownership
```

### "402 Payment Required"
```bash
# Scoped packages in organizations need --access public
npm publish --access public
```

### Git Push Rejected
```bash
# If remote repository has content you don't have locally
git pull --rebase origin main
git push origin main
```

## Useful Commands

```bash
# View published package info
npm view @appollo-ui/sf-plugin-deploy-hooks

# View all versions
npm view @appollo-ui/sf-plugin-deploy-hooks versions

# Unpublish (only within 72 hours, not recommended)
npm unpublish @appollo-ui/sf-plugin-deploy-hooks@2.0.0

# Deprecate a version (preferred over unpublish)
npm deprecate @appollo-ui/sf-plugin-deploy-hooks@2.0.0 "Deprecated due to..."

# Check what files will be included in package
npm pack --dry-run
```

## Support

- GitHub Issues: https://github.com/appollo-ui/sf-plugin-deploy-hooks/issues
- npm Package: https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks
