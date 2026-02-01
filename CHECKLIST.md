# Pre-Publication Checklist

Use this checklist before publishing to npm and GitHub.

## Code Quality

- [x] All TypeScript files compile without errors
- [x] Package builds successfully (`npm run build`)
- [x] No sensitive data in code (API keys, tokens, etc.)
- [x] Examples are executable and tested
- [x] README is complete and accurate

## Package Configuration

- [x] package.json has correct scoped name: `@appollo-ui/sf-plugin-deploy-hooks`
- [x] Version number is correct (2.0.0)
- [x] Description is accurate
- [x] Keywords are relevant
- [x] Repository URL is set
- [x] License is specified (MIT)
- [x] Files array includes necessary files (lib, examples, README.md, LICENSE)
- [x] Homepage URL is set
- [x] prepublishOnly script is configured

## Documentation

- [x] README.md includes:
  - [x] Installation instructions
  - [x] Configuration examples
  - [x] Usage examples
  - [x] AI-powered error analysis example
  - [x] Environment variables documented
  - [x] Links to repository and npm
- [x] LICENSE file exists
- [x] Examples directory has README.md
- [x] QUICKSTART.md for AI features
- [x] PUBLISHING.md guide created

## Files

- [x] .gitignore configured
- [x] .npmignore configured
- [x] lib/ directory excluded from git (built files)
- [x] examples/ included in npm package
- [x] No unnecessary files in package

## Testing

- [ ] Test `npm pack` to verify package contents
- [ ] Test local installation: `sf plugins install ./package.tgz`
- [ ] Verify plugin appears in `sf plugins`
- [ ] Test with a sample `.sfhooks.json` configuration
- [ ] Test pre-deploy hooks execute
- [ ] Test post-deploy hooks execute
- [ ] Test deploy result JSON is created
- [ ] Test AI analysis script works (if Copilot installed)

## npm Setup

- [ ] Logged into npm: `npm whoami`
- [ ] Member of @appollo-ui organization: `npm org ls appollo-ui`
- [ ] Organization has public packages enabled

## GitHub Setup

- [ ] GitHub account ready
- [ ] Access to create repos in appollo-ui organization (or will use personal)
- [ ] gh CLI installed and authenticated (optional but recommended)

## Ready to Publish?

Once all items are checked:

```bash
# 1. Initialize Git
git init
git add .
git commit -m "Initial commit: SF CLI Deploy Hooks Plugin v2.0.0"

# 2. Create GitHub repo (using gh CLI)
gh repo create appollo-ui/sf-plugin-deploy-hooks --public \
  --description "SF CLI plugin for pre/post-deploy hooks with AI-powered error analysis"

# 3. Push to GitHub
git remote add origin https://github.com/appollo-ui/sf-plugin-deploy-hooks.git
git branch -M main
git push -u origin main
git tag -a v2.0.0 -m "Release v2.0.0"
git push origin v2.0.0

# 4. Publish to npm
npm publish --access public

# 5. Verify
npm view @appollo-ui/sf-plugin-deploy-hooks
sf plugins install @appollo-ui/sf-plugin-deploy-hooks
```

See `PUBLISHING.md` for detailed step-by-step instructions.
