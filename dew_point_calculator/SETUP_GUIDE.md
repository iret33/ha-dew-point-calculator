# Setup and Publishing Guide

This guide will help you publish your Dew Point Calculator integration to GitHub and HACS.

## Step 1: Prepare the Repository

### Update Personal Information

Replace the following placeholders in all files:

1. **In `manifest.json`**:
   - Replace `iret33` with your GitHub username
   - Replace `@iret33` with your GitHub username in codeowners

2. **In `README.md`**:
   - Replace all instances of `iret33` with your GitHub username

3. **In `LICENSE`**:
   - Replace `[Your Name]` with your actual name

4. **In `CONTRIBUTING.md`**:
   - Replace `iret33` with your GitHub username

## Step 2: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the **+** icon → **New repository**
3. Name it: `ha-dew-point-calculator`
4. Make it **Public** (required for HACS)
5. Don't initialize with README (we already have one)
6. Click **Create repository**

## Step 3: Push Your Code

In your terminal, navigate to the project folder and run:

```bash
cd dew_point_calculator
git init
git add .
git commit -m "Initial commit: Dew Point Calculator v1.0.0"
git branch -M main
git remote add origin https://github.com/iret33/ha-dew-point-calculator.git
git push -u origin main
```

## Step 4: Create a Release

1. Go to your repository on GitHub
2. Click **Releases** → **Create a new release**
3. Click **Choose a tag** → type `v1.0.0` → **Create new tag**
4. Release title: `v1.0.0 - Initial Release`
5. Description:
   ```markdown
   ## Features
   - UI-based configuration
   - Real-time dew point calculation using Magnus formula
   - Support for multiple sensor combinations
   - Automatic updates when sensors change
   
   ## Installation
   See README for installation instructions
   ```
6. Click **Publish release**

## Step 5: Test Installation

### Manual Test

1. Copy the `custom_components/dew_point_calculator` folder to your Home Assistant
2. Place it in: `config/custom_components/`
3. Restart Home Assistant
4. Go to Settings → Devices & Services → Add Integration
5. Search for "Dew Point Calculator"
6. Test the configuration flow

### HACS Test (before official submission)

1. In HACS, go to Integrations
2. Click three dots → Custom repositories
3. Add: `https://github.com/iret33/ha-dew-point-calculator`
4. Category: Integration
5. Click Add
6. Find and install "Dew Point Calculator"
7. Restart and test

## Step 6: Submit to HACS Default Repository

Once you've tested and everything works:

1. Go to [HACS Default Repository](https://github.com/hacs/default)
2. Fork the repository
3. Edit `integration` file
4. Add your repository in alphabetical order:
   ```
   iret33/ha-dew-point-calculator
   ```
5. Commit changes
6. Create a Pull Request with title: "Add Dew Point Calculator"
7. Fill in the PR template
8. Wait for review and approval

## Step 7: Maintain Your Integration

### For Updates

1. Make your changes
2. Update version in `manifest.json`
3. Commit and push changes
4. Create a new release on GitHub with the new version tag

### For Bug Reports

- Monitor GitHub Issues
- Respond to user questions
- Fix bugs and release updates

## Checklist Before Submitting to HACS

- [ ] All files use your actual GitHub username
- [ ] Repository is public
- [ ] At least one release exists (v1.0.0)
- [ ] README.md is complete
- [ ] hacs.json is present
- [ ] Integration works when installed manually
- [ ] Integration works when installed via HACS custom repo
- [ ] No errors in Home Assistant logs
- [ ] Config flow works correctly
- [ ] Sensor updates in real-time

## Common Issues

**Integration doesn't show in Add Integration**
- Restart Home Assistant
- Check logs for errors
- Verify all files are in correct locations

**HACS can't find the repository**
- Ensure repository is public
- Check that you have at least one release
- Verify hacs.json is in the root

**Sensor shows unavailable**
- Check that source sensors exist
- Verify sensor entity IDs are correct
- Look for errors in Home Assistant logs

## Support

If you need help:
- Check [Home Assistant Developer Docs](https://developers.home-assistant.io/)
- Join [Home Assistant Discord](https://discord.gg/home-assistant)
- Ask on [Home Assistant Community](https://community.home-assistant.io/)

Good luck with your integration! 🎉
