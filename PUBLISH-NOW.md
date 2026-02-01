# Quick Start: Publishing to npm and GitHub

## TL;DR - Copy & Paste Commands

**Prerequisites:** You need npm access to `@appollo-ui` org and GitHub access to `appollo-ui` org.

```bash
# Navigate to project
cd /Users/matt/Dev/@appollo-ui/sf-plugin-deploy-hooks

# 1. Login to npm
npm login

# 2. Verify build
npm run clean && npm run build

# 3. Test package locally (optional)
npm pack
sf plugins install ./appollo-ui-sf-plugin-deploy-hooks-2.0.0.tgz
sf plugins
rm appollo-ui-sf-plugin-deploy-hooks-2.0.0.tgz
sf plugins uninstall @appollo-ui/sf-plugin-deploy-hooks

# 4. Initialize Git
git init
git add .
git commit -m "Initial commit: SF CLI Deploy Hooks Plugin v2.0.0"

# 5. Create GitHub repository
gh auth login  # if not logged in
gh repo create appollo-ui/sf-plugin-deploy-hooks --public \
  --description "SF CLI plugin for pre/post-deploy hooks with AI-powered error analysis" \
  --homepage "https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks"

# 6. Push to GitHub
git remote add origin https://github.com/appollo-ui/sf-plugin-deploy-hooks.git
git branch -M main
git push -u origin main

# 7. Tag release
git tag -a v2.0.0 -m "Release v2.0.0: Initial release with AI-powered error analysis"
git push origin v2.0.0

# 8. Publish to npm
npm publish --access public

# 9. Verify publication
npm view @appollo-ui/sf-plugin-deploy-hooks
echo "✅ Published! Install with: sf plugins install @appollo-ui/sf-plugin-deploy-hooks"

# 10. Test installation
sf plugins install @appollo-ui/sf-plugin-deploy-hooks
sf plugins | grep deploy-hooks
```

## Alternative: Manual GitHub Repo Creation

If `gh` CLI doesn't work or you prefer web UI:

1. Go to: https://github.com/organizations/appollo-ui/repositories/new
2. Repository name: `sf-plugin-deploy-hooks`
3. Description: "SF CLI plugin for pre/post-deploy hooks with AI-powered error analysis"
4. Public
5. **DO NOT** initialize with README, .gitignore, or license
6. Click "Create repository"
7. Follow the commands shown on the next page

## What Gets Published

### npm Package Includes:
- ✅ `lib/` - Compiled JavaScript and TypeScript definitions
- ✅ `examples/` - All example scripts and documentation
- ✅ `README.md` - Full documentation
- ✅ `LICENSE` - MIT license
- ✅ `package.json` - Package metadata

### npm Package Excludes:
- ❌ `src/` - TypeScript source (not needed, lib/ has compiled code)
- ❌ `node_modules/` - Dependencies
- ❌ `.git/` - Git history
- ❌ Development files

### GitHub Repository Includes:
- Everything (source + built files initially)
- You can add `lib/` to .gitignore after first push if desired

## Verification Checklist

After publishing, verify:

```bash
# 1. Check npm
npm view @appollo-ui/sf-plugin-deploy-hooks

# 2. Check version
npm view @appollo-ui/sf-plugin-deploy-hooks version

# 3. Check files included
npm view @appollo-ui/sf-plugin-deploy-hooks files

# 4. Install and test
sf plugins install @appollo-ui/sf-plugin-deploy-hooks
sf plugins

# 5. Check GitHub
open https://github.com/appollo-ui/sf-plugin-deploy-hooks

# 6. Check npm page
open https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks
```

## Post-Publication Tasks

```bash
# 1. Create GitHub release
gh release create v2.0.0 \
  --title "v2.0.0 - Initial Release" \
  --notes-file - << 'EOF'
## Features

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

Full documentation: https://github.com/appollo-ui/sf-plugin-deploy-hooks
EOF

# 2. Add repository topics
gh repo edit appollo-ui/sf-plugin-deploy-hooks \
  --add-topic salesforce \
  --add-topic sf-cli \
  --add-topic sfdx-plugin \
  --add-topic deploy-hooks \
  --add-topic ci-cd \
  --add-topic ai-analysis

# 3. Star your own repo (optional but fun!)
gh repo view appollo-ui/sf-plugin-deploy-hooks --web
```

## Troubleshooting

**"You do not have permission to publish"**
```bash
npm whoami  # Check you're logged in
npm org ls appollo-ui  # Check you're in the org
```

**"402 Payment Required"**
```bash
# Use --access public for scoped packages
npm publish --access public
```

**"Repository already exists"**
```bash
# Use the existing repo
git remote add origin https://github.com/appollo-ui/sf-plugin-deploy-hooks.git
git push -u origin main
```

## Support

- 📖 Detailed guide: See `PUBLISHING.md`
- ✅ Pre-publish checklist: See `CHECKLIST.md`
- 🐛 Issues: https://github.com/appollo-ui/sf-plugin-deploy-hooks/issues
