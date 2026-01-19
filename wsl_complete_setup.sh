#!/bin/bash

# Complete Dew Point Calculator Publishing Script for WSL Ubuntu on Windows 11
# This script handles EVERYTHING from start to finish

set -e  # Exit on error

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
print_success() { echo -e "${GREEN}✓ ${NC}$1"; }
print_warning() { echo -e "${YELLOW}⚠ ${NC}$1"; }
print_error() { echo -e "${RED}✗ ${NC}$1"; }
print_header() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║  $(printf '%-58s' "$1")  ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Welcome banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   ██████╗ ███████╗██╗    ██╗    ██████╗  ██████╗ ██╗███╗   ██╗╚
║   ██╔══██╗██╔════╝██║    ██║    ██╔══██╗██╔═══██╗██║████╗  ██║║
║   ██║  ██║█████╗  ██║ █╗ ██║    ██████╔╝██║   ██║██║██╔██╗ ██║║
║   ██║  ██║██╔══╝  ██║███╗██║    ██╔═══╝ ██║   ██║██║██║╚██╗██║║
║   ██████╔╝███████╗╚███╔███╔╝    ██║     ╚██████╔╝██║██║ ╚████║║
║   ╚═════╝ ╚══════╝ ╚══╝╚══╝     ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝║
║                                                                ║
║         Complete Setup & Publishing Tool for WSL Ubuntu        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "This script will:"
echo "  1. ✓ Check and install required dependencies"
echo "  2. ✓ Copy files from Windows to WSL"
echo "  3. ✓ Update files with your information"
echo "  4. ✓ Initialize git repositories"
echo "  5. ✓ Create GitHub repositories"
echo "  6. ✓ Push code to GitHub"
echo "  7. ✓ Create releases"
echo "  8. ✓ Open repositories in Windows browser"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# ============================================================================
# STEP 1: Check WSL Environment and Dependencies
# ============================================================================

print_header "Step 1: Checking WSL Environment"

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    print_error "This script must be run in WSL (Windows Subsystem for Linux)"
    exit 1
fi

print_success "Running in WSL Ubuntu"

# Check Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "Detected: $NAME $VERSION"
fi

# Check and install git
print_info "Checking for git..."
if ! command -v git &> /dev/null; then
    print_warning "Git not found. Installing..."
    sudo apt update
    sudo apt install -y git
    print_success "Git installed"
else
    print_success "Git is already installed ($(git --version))"
fi

# Check and install GitHub CLI
print_info "Checking for GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI not found. Installing..."
    
    # Add GitHub CLI repository
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    sudo apt update
    sudo apt install -y gh
    
    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI is already installed ($(gh --version | head -1))"
fi

# Check for wslview (to open browser in Windows)
print_info "Checking for wslview (Windows browser integration)..."
if ! command -v wslview &> /dev/null; then
    print_warning "wslview not found. Installing wslu..."
    sudo apt install -y wslu
    print_success "wslu installed"
else
    print_success "wslview is available"
fi

# ============================================================================
# STEP 2: Locate or Copy Files
# ============================================================================

print_header "Step 2: Locating Project Files"

# Default paths to check
WINDOWS_DOWNLOADS="/mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')/Downloads"
WSL_HOME="$HOME"
PROJECT_DIR="$WSL_HOME/dew-point-projects"

print_info "Looking for project files..."

# Check if files exist in common locations
FOUND_HA=false
FOUND_ESPHOME=false

# Check Downloads folder
if [ -d "$WINDOWS_DOWNLOADS/dew_point_calculator" ]; then
    HA_SOURCE="$WINDOWS_DOWNLOADS/dew_point_calculator"
    FOUND_HA=true
    print_success "Found Home Assistant integration in Windows Downloads"
fi

if [ -d "$WINDOWS_DOWNLOADS/esphome_dew_point" ]; then
    ESPHOME_SOURCE="$WINDOWS_DOWNLOADS/esphome_dew_point"
    FOUND_ESPHOME=true
    print_success "Found ESPHome component in Windows Downloads"
fi

# If not found, ask user
if [ "$FOUND_HA" = false ]; then
    echo ""
    print_warning "Home Assistant integration not found automatically"
    read -p "Enter full Windows path to dew_point_calculator folder (or press Enter to skip): " HA_PATH
    if [ -n "$HA_PATH" ]; then
        # Convert Windows path to WSL path if needed
        if [[ "$HA_PATH" =~ ^[A-Z]:\\ ]]; then
            HA_SOURCE=$(wslpath "$HA_PATH")
        else
            HA_SOURCE="$HA_PATH"
        fi
        if [ -d "$HA_SOURCE" ]; then
            FOUND_HA=true
        fi
    fi
fi

if [ "$FOUND_ESPHOME" = false ]; then
    echo ""
    print_warning "ESPHome component not found automatically"
    read -p "Enter full Windows path to esphome_dew_point folder (or press Enter to skip): " ESPHOME_PATH
    if [ -n "$ESPHOME_PATH" ]; then
        # Convert Windows path to WSL path if needed
        if [[ "$ESPHOME_PATH" =~ ^[A-Z]:\\ ]]; then
            ESPHOME_SOURCE=$(wslpath "$ESPHOME_PATH")
        else
            ESPHOME_SOURCE="$ESPHOME_PATH"
        fi
        if [ -d "$ESPHOME_SOURCE" ]; then
            FOUND_ESPHOME=true
        fi
    fi
fi

# Create project directory
mkdir -p "$PROJECT_DIR"
print_success "Created working directory: $PROJECT_DIR"

# Copy files to WSL
if [ "$FOUND_HA" = true ]; then
    print_info "Copying Home Assistant integration..."
    cp -r "$HA_SOURCE" "$PROJECT_DIR/ha-dew-point-calculator"
    print_success "Copied to: $PROJECT_DIR/ha-dew-point-calculator"
fi

if [ "$FOUND_ESPHOME" = true ]; then
    print_info "Copying ESPHome component..."
    cp -r "$ESPHOME_SOURCE" "$PROJECT_DIR/esphome-dew-point"
    print_success "Copied to: $PROJECT_DIR/esphome-dew-point"
fi

# Verify at least one project was found
if [ "$FOUND_HA" = false ] && [ "$FOUND_ESPHOME" = false ]; then
    print_error "No project files found. Please download the zip files first."
    exit 1
fi

# ============================================================================
# STEP 3: Collect User Information
# ============================================================================

print_header "Step 3: Your Information"

read -p "Enter your GitHub username: " GITHUB_USERNAME
while [ -z "$GITHUB_USERNAME" ]; do
    print_error "GitHub username is required"
    read -p "Enter your GitHub username: " GITHUB_USERNAME
done

read -p "Enter your full name (for license): " FULL_NAME
while [ -z "$FULL_NAME" ]; do
    print_error "Full name is required"
    read -p "Enter your full name (for license): " FULL_NAME
done

read -p "Enter your email (for git config): " EMAIL

# Configure git
print_info "Configuring git..."
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL"
print_success "Git configured"

# ============================================================================
# STEP 4: GitHub CLI Login
# ============================================================================

print_header "Step 4: GitHub Authentication"

print_info "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    print_warning "Not logged in to GitHub"
    echo ""
    print_info "You'll now be prompted to login to GitHub"
    echo "  1. Choose 'GitHub.com'"
    echo "  2. Choose 'HTTPS'"
    echo "  3. Choose 'Login with a web browser'"
    echo "  4. A browser will open - login and authorize"
    echo ""
    read -p "Press Enter to start GitHub login..."
    
    gh auth login
    
    if gh auth status &> /dev/null; then
        print_success "Successfully logged in to GitHub"
    else
        print_error "GitHub login failed. Please try again."
        exit 1
    fi
else
    print_success "Already logged in to GitHub as $(gh api user -q .login)"
fi

# ============================================================================
# STEP 5: Update Files with User Information
# ============================================================================

print_header "Step 5: Updating Files with Your Information"

update_project_files() {
    local dir=$1
    local name=$2
    
    print_info "Updating $name..."
    
    cd "$dir"
    
    # Update username in all markdown, JSON, and YAML files
    find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) \
        -exec sed -i "s/yourusername/$GITHUB_USERNAME/g" {} \; 2>/dev/null || true
    
    # Update name in LICENSE
    if [ -f "LICENSE" ]; then
        sed -i "s/\[Your Name\]/$FULL_NAME/g" LICENSE
    fi
    
    # Update manifest.json for HA integration
    if [ -f "custom_components/dew_point_calculator/manifest.json" ]; then
        sed -i "s/@yourusername/@$GITHUB_USERNAME/g" custom_components/dew_point_calculator/manifest.json
    fi
    
    print_success "$name updated"
}

if [ "$FOUND_HA" = true ]; then
    update_project_files "$PROJECT_DIR/ha-dew-point-calculator" "Home Assistant Integration"
fi

if [ "$FOUND_ESPHOME" = true ]; then
    update_project_files "$PROJECT_DIR/esphome-dew-point" "ESPHome Component"
fi

# ============================================================================
# STEP 6: Initialize Git Repositories
# ============================================================================

print_header "Step 6: Initializing Git Repositories"

init_git_repo() {
    local dir=$1
    local name=$2
    local description=$3
    
    print_info "Initializing git for $name..."
    
    cd "$dir"
    
    # Remove any existing git repo
    rm -rf .git
    
    # Initialize
    git init
    git add .
    git commit -m "Initial commit: $description v1.0.0

- Complete implementation with Magnus formula
- Comprehensive documentation and examples
- Ready for production use
- MIT licensed"
    
    git branch -M main
    
    print_success "Git initialized for $name"
}

if [ "$FOUND_HA" = true ]; then
    init_git_repo "$PROJECT_DIR/ha-dew-point-calculator" \
                  "Home Assistant Integration" \
                  "Home Assistant Dew Point Calculator"
fi

if [ "$FOUND_ESPHOME" = true ]; then
    init_git_repo "$PROJECT_DIR/esphome-dew-point" \
                  "ESPHome Component" \
                  "ESPHome Dew Point Component"
fi

# ============================================================================
# STEP 7: Create GitHub Repositories
# ============================================================================

print_header "Step 7: Creating GitHub Repositories"

create_github_repo() {
    local dir=$1
    local repo_name=$2
    local description=$3
    
    print_info "Creating GitHub repository: $repo_name"
    
    cd "$dir"
    
    # Check if repo already exists
    if gh repo view "$GITHUB_USERNAME/$repo_name" &> /dev/null; then
        print_warning "Repository $repo_name already exists"
        read -p "Delete and recreate? (yes/no): " RECREATE
        if [ "$RECREATE" = "yes" ]; then
            print_info "Deleting existing repository..."
            gh repo delete "$GITHUB_USERNAME/$repo_name" --yes
            sleep 2
        else
            print_info "Using existing repository"
            return 0
        fi
    fi
    
    # Create repository
    gh repo create "$repo_name" \
        --public \
        --description "$description" \
        --source=. \
        --remote=origin \
        --push
    
    if [ $? -eq 0 ]; then
        print_success "Repository created and pushed: https://github.com/$GITHUB_USERNAME/$repo_name"
        return 0
    else
        print_error "Failed to create repository: $repo_name"
        return 1
    fi
}

REPO_HA_CREATED=false
REPO_ESPHOME_CREATED=false

if [ "$FOUND_HA" = true ]; then
    if create_github_repo "$PROJECT_DIR/ha-dew-point-calculator" \
                          "ha-dew-point-calculator" \
                          "Home Assistant integration for calculating dew point from temperature and humidity sensors"; then
        REPO_HA_CREATED=true
    fi
fi

if [ "$FOUND_ESPHOME" = true ]; then
    if create_github_repo "$PROJECT_DIR/esphome-dew-point" \
                          "esphome-dew-point" \
                          "ESPHome custom component for calculating dew point from temperature and humidity sensors"; then
        REPO_ESPHOME_CREATED=true
    fi
fi

# ============================================================================
# STEP 8: Create Releases
# ============================================================================

print_header "Step 8: Creating v1.0.0 Releases"

create_release() {
    local dir=$1
    local repo_name=$2
    local title=$3
    
    print_info "Creating release for $repo_name..."
    
    cd "$dir"
    
    # Create release
    gh release create v1.0.0 \
        --repo "$GITHUB_USERNAME/$repo_name" \
        --title "$title" \
        --notes "First stable release with complete implementation and documentation" \
        --latest
    
    if [ $? -eq 0 ]; then
        print_success "Release v1.0.0 created for $repo_name"
        return 0
    else
        print_warning "Could not create release (may already exist)"
        return 1
    fi
}

if [ "$REPO_HA_CREATED" = true ]; then
    create_release "$PROJECT_DIR/ha-dew-point-calculator" \
                   "ha-dew-point-calculator" \
                   "v1.0.0 - Home Assistant Dew Point Calculator"
fi

if [ "$REPO_ESPHOME_CREATED" = true ]; then
    create_release "$PROJECT_DIR/esphome-dew-point" \
                   "esphome-dew-point" \
                   "v1.0.0 - ESPHome Dew Point Component"
fi

# ============================================================================
# STEP 9: Add Topics/Tags
# ============================================================================

print_header "Step 9: Adding Repository Topics"

add_topics() {
    local repo_name=$1
    shift
    local topics=("$@")
    
    print_info "Adding topics to $repo_name..."
    
    for topic in "${topics[@]}"; do
        gh repo edit "$GITHUB_USERNAME/$repo_name" --add-topic "$topic" 2>/dev/null
    done
    
    print_success "Topics added to $repo_name"
}

if [ "$REPO_HA_CREATED" = true ]; then
    add_topics "ha-dew-point-calculator" \
               "home-assistant" "hacs" "custom-integration" \
               "dew-point" "sensor" "temperature" "humidity"
fi

if [ "$REPO_ESPHOME_CREATED" = true ]; then
    add_topics "esphome-dew-point" \
               "esphome" "home-assistant" "custom-component" \
               "dew-point" "sensor" "esp8266" "esp32"
fi

# ============================================================================
# STEP 10: Open Repositories in Browser
# ============================================================================

print_header "Step 10: Opening Repositories"

open_in_browser() {
    local url=$1
    print_info "Opening in Windows browser: $url"
    wslview "$url" 2>/dev/null || cmd.exe /c start "$url" 2>/dev/null || true
    sleep 1
}

if [ "$REPO_HA_CREATED" = true ]; then
    open_in_browser "https://github.com/$GITHUB_USERNAME/ha-dew-point-calculator"
fi

if [ "$REPO_ESPHOME_CREATED" = true ]; then
    open_in_browser "https://github.com/$GITHUB_USERNAME/esphome-dew-point"
fi

# ============================================================================
# FINAL SUMMARY
# ============================================================================

print_header "🎉 SETUP COMPLETE!"

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    SUCCESS SUMMARY                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$REPO_HA_CREATED" = true ]; then
    echo -e "${CYAN}📦 Home Assistant Integration${NC}"
    echo -e "   Repository: ${YELLOW}https://github.com/$GITHUB_USERNAME/ha-dew-point-calculator${NC}"
    echo -e "   Release: ${GREEN}v1.0.0${NC}"
    echo ""
    echo "   Installation:"
    echo "   1. Add to HACS as custom repository"
    echo "   2. Search and install 'Dew Point Calculator'"
    echo "   3. Restart Home Assistant"
    echo "   4. Add integration via UI"
    echo ""
fi

if [ "$REPO_ESPHOME_CREATED" = true ]; then
    echo -e "${CYAN}🔌 ESPHome Component${NC}"
    echo -e "   Repository: ${YELLOW}https://github.com/$GITHUB_USERNAME/esphome-dew-point${NC}"
    echo -e "   Release: ${GREEN}v1.0.0${NC}"
    echo ""
    echo "   Usage in ESPHome:"
    echo "   external_components:"
    echo "     - source: github://$GITHUB_USERNAME/esphome-dew-point@v1.0.0"
    echo "       components: [ dew_point ]"
    echo ""
fi

echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. ⭐ Star your own repositories to boost them"
echo "  2. 📝 Review the README files in each repository"
echo "  3. 🧪 Test the integrations locally"
echo "  4. 📢 Announce on:"
echo "     - ESPHome Discord: https://discord.gg/KhAMKrd"
echo "     - Home Assistant Forums: https://community.home-assistant.io/"
echo "     - Reddit: r/homeassistant"
echo "  5. 📦 Submit to HACS (for HA integration)"
echo ""

echo -e "${MAGENTA}📁 Local Files Location:${NC}"
echo "   $PROJECT_DIR"
echo ""

echo -e "${GREEN}All repositories have been successfully published! 🚀${NC}"
echo ""

# Save summary to file
SUMMARY_FILE="$PROJECT_DIR/PUBLISHING_SUMMARY.txt"
cat > "$SUMMARY_FILE" << EOF
Dew Point Calculator - Publishing Summary
Generated: $(date)

GitHub Username: $GITHUB_USERNAME
Full Name: $FULL_NAME

Repositories Published:
EOF

if [ "$REPO_HA_CREATED" = true ]; then
    cat >> "$SUMMARY_FILE" << EOF

1. Home Assistant Integration
   URL: https://github.com/$GITHUB_USERNAME/ha-dew-point-calculator
   Release: v1.0.0
   Topics: home-assistant, hacs, custom-integration, dew-point, sensor
EOF
fi

if [ "$REPO_ESPHOME_CREATED" = true ]; then
    cat >> "$SUMMARY_FILE" << EOF

2. ESPHome Component
   URL: https://github.com/$GITHUB_USERNAME/esphome-dew-point
   Release: v1.0.0
   Topics: esphome, home-assistant, custom-component, dew-point, esp8266, esp32
EOF
fi

cat >> "$SUMMARY_FILE" << EOF

Local Files: $PROJECT_DIR

Next Steps:
- Star your repositories
- Test integrations
- Share with community
- Submit to HACS
EOF

print_success "Summary saved to: $SUMMARY_FILE"

# Final question
echo ""
read -p "Would you like to open the summary file? (y/n): " OPEN_SUMMARY
if [ "$OPEN_SUMMARY" = "y" ] || [ "$OPEN_SUMMARY" = "Y" ]; then
    wslview "$SUMMARY_FILE" 2>/dev/null || cat "$SUMMARY_FILE"
fi

echo ""
print_success "Thank you for using this setup script! Good luck with your projects! 🎊"
echo ""
