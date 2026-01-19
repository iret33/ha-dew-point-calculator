# Complete Setup Guide for WSL Ubuntu on Windows 11

## 🚀 One-Command Solution

This single script does EVERYTHING automatically:
- ✅ Installs required tools (git, GitHub CLI)
- ✅ Finds and copies your project files
- ✅ Updates all files with your information
- ✅ Creates GitHub repositories
- ✅ Pushes code and creates releases
- ✅ Opens repositories in your Windows browser

## 📋 Prerequisites

1. **WSL Ubuntu must be installed** on Windows 11
2. **Download the zip files** from Claude:
   - `dew_point_calculator.zip` (Home Assistant)
   - `esphome_dew_point.zip` (ESPHome)
3. **Extract both zips** to your Windows Downloads folder

## 🎯 Quick Start (Copy and Paste These Commands)

### Step 1: Open WSL Ubuntu Terminal

In Windows 11:
1. Press `Windows + X`
2. Click "Terminal" or "Windows Terminal"
3. Type `wsl` and press Enter (if not already in Ubuntu)

OR

1. Search for "Ubuntu" in Start Menu
2. Open the Ubuntu app

### Step 2: Download and Run the Setup Script

Copy and paste this entire block into your WSL Ubuntu terminal:

```bash
# Download the setup script
curl -o ~/wsl_complete_setup.sh https://raw.githubusercontent.com/iret33/temp/main/wsl_complete_setup.sh

# Make it executable
chmod +x ~/wsl_complete_setup.sh

# Run it
~/wsl_complete_setup.sh
```

**OR** if you already have the script file:

```bash
# Navigate to where you saved the script
cd ~/Downloads  # or wherever you saved it

# Make it executable
chmod +x wsl_complete_setup.sh

# Run it
./wsl_complete_setup.sh
```

### Step 3: Follow the Interactive Prompts

The script will ask you for:
1. **GitHub Username** (e.g., `iret33`)
2. **Full Name** (e.g., `John Smith`)
3. **Email** (e.g., `john@example.com`)

Then it will:
- Install necessary tools (if not present)
- Find your project files automatically
- Login to GitHub (opens browser)
- Create repositories
- Push everything
- Create releases
- Open repositories in browser

## 🎬 Complete Copy-Paste Solution

If you want to do it all in ONE go, here's the complete command block:

```bash
# Step 1: Navigate to home directory
cd ~

# Step 2: Create the script (paste the entire script content)
cat > wsl_complete_setup.sh << 'SCRIPT_END'
[PASTE THE ENTIRE SCRIPT CONTENT HERE]
SCRIPT_END

# Step 3: Make executable and run
chmod +x wsl_complete_setup.sh
./wsl_complete_setup.sh
```

## 📍 Where Are My Files?

### Before Script Runs:
- Windows Downloads: `C:\Users\YourName\Downloads\`
  - `dew_point_calculator\` (extracted)
  - `esphome_dew_point\` (extracted)

### After Script Runs:
- WSL Ubuntu: `~/dew-point-projects/`
  - `ha-dew-point-calculator/`
  - `esphome-dew-point/`

### On GitHub:
- `https://github.com/iret33/ha-dew-point-calculator`
- `https://github.com/iret33/esphome-dew-point`

## ⚡ Alternative: Manual Step-by-Step Commands

If you prefer to run commands manually:

### 1. Install Dependencies

```bash
# Update package list
sudo apt update

# Install git
sudo apt install -y git

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Install wslu (for opening Windows browser)
sudo apt install -y wslu
```

### 2. Setup Variables

```bash
export GITHUB_USERNAME="your_github_username"
export FULL_NAME="Your Full Name"
export EMAIL="your@email.com"

# Configure git
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL"
```

### 3. Login to GitHub

```bash
gh auth login
# Choose: GitHub.com → HTTPS → Login with web browser
```

### 4. Copy Files from Windows

```bash
# Create working directory
mkdir -p ~/dew-point-projects

# Copy from Windows Downloads (adjust path if needed)
WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
cp -r "/mnt/c/Users/$WINDOWS_USER/Downloads/dew_point_calculator" ~/dew-point-projects/ha-dew-point-calculator
cp -r "/mnt/c/Users/$WINDOWS_USER/Downloads/esphome_dew_point" ~/dew-point-projects/esphome-dew-point
```

### 5. Update Home Assistant Integration

```bash
cd ~/dew-point-projects/ha-dew-point-calculator

# Update files
find . -type f \( -name "*.md" -o -name "*.json" \) -exec sed -i "s/iret33/$GITHUB_USERNAME/g" {} \;
sed -i "s/\[Your Name\]/$FULL_NAME/g" LICENSE
sed -i "s/@iret33/@$GITHUB_USERNAME/g" custom_components/dew_point_calculator/manifest.json

# Initialize git
git init
git add .
git commit -m "Initial commit: Home Assistant Dew Point Calculator v1.0.0"
git branch -M main

# Create GitHub repo and push
gh repo create ha-dew-point-calculator --public --description "Home Assistant integration for dew point calculation" --source=. --remote=origin --push

# Create release
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes "First stable release"

# Add topics
gh repo edit ha-dew-point-calculator --add-topic home-assistant --add-topic hacs --add-topic custom-integration --add-topic dew-point

# Open in browser
wslview "https://github.com/$GITHUB_USERNAME/ha-dew-point-calculator"
```

### 6. Update ESPHome Component

```bash
cd ~/dew-point-projects/esphome-dew-point

# Update files
find . -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) -exec sed -i "s/iret33/$GITHUB_USERNAME/g" {} \;
sed -i "s/\[Your Name\]/$FULL_NAME/g" LICENSE

# Initialize git
git init
git add .
git commit -m "Initial commit: ESPHome Dew Point Component v1.0.0"
git branch -M main

# Create GitHub repo and push
gh repo create esphome-dew-point --public --description "ESPHome component for dew point calculation" --source=. --remote=origin --push

# Create release
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes "First stable release"

# Add topics
gh repo edit esphome-dew-point --add-topic esphome --add-topic home-assistant --add-topic custom-component --add-topic dew-point

# Open in browser
wslview "https://github.com/$GITHUB_USERNAME/esphome-dew-point"
```

## 🔧 Troubleshooting

### "Command not found" errors
```bash
# Refresh your environment
source ~/.bashrc
hash -r
```

### Can't find files in Windows Downloads
```bash
# List what's in your Windows Downloads
ls -la /mnt/c/Users/*/Downloads/

# Or check your actual username
cmd.exe /c "echo %USERNAME%"
```

### GitHub authentication fails
```bash
# Re-login
gh auth logout
gh auth login
```

### Permission denied on script
```bash
chmod +x wsl_complete_setup.sh
```

### Can't open browser from WSL
```bash
# Install wslu
sudo apt install -y wslu

# Test it
wslview https://google.com
```

## 📊 What You'll See

The script shows colored output:
- 🔵 **Blue (ℹ)** = Information
- 🟢 **Green (✓)** = Success
- 🟡 **Yellow (⚠)** = Warning
- 🔴 **Red (✗)** = Error

Example output:
```
╔══════════════════════════════════════════════════════════════╗
║         Complete Setup & Publishing Tool for WSL Ubuntu        ║
╚══════════════════════════════════════════════════════════════╝

ℹ Checking for git...
✓ Git is already installed (git version 2.34.1)

ℹ Creating GitHub repository: ha-dew-point-calculator
✓ Repository created and pushed: https://github.com/username/ha-dew-point-calculator
```

## ✅ Success Indicators

You'll know it worked when:
1. Script says "✓ Repository created and pushed"
2. Browser opens with your GitHub repositories
3. You see the green "v1.0.0" release tag
4. All files are visible on GitHub

## 📝 After Success

Your repositories will be at:
- `https://github.com/YourUsername/ha-dew-point-calculator`
- `https://github.com/YourUsername/esphome-dew-point`

Next steps:
1. ⭐ Star your own repositories
2. Read the README files
3. Test installations
4. Share with the community

## 🆘 Need Help?

If something goes wrong:
1. Check the error message in red
2. Make sure you extracted the zip files
3. Verify your GitHub username is correct
4. Try the manual commands one by one
5. Check that WSL Ubuntu is updated: `sudo apt update && sudo apt upgrade`

## 💡 Pro Tips

1. **Keep the terminal open** until everything completes
2. **Copy exact commands** - don't modify them
3. **Read prompts carefully** - especially during GitHub login
4. **Save the summary file** that gets created at the end
5. **Take screenshots** of success messages

---

**That's it!** One script, everything done. Good luck! 🚀
