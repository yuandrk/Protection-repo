#!/bin/sh

# Author: Yurii Andriuk
# Date Created: 01-01-24
# Description: Gitleaks installation script
# Version: 1.0.2
# License: GNU General Public License (GPL)

print_header() {
    echo "========================================"
    echo " Gitleaks Installation Script"
    echo "========================================"
    echo " Version: 1.0.1"
    echo " Author: Yurii Andriuk (yurii.andriuk@gmail.com)"
    echo " Date Created: 01-01-24"
    echo " Description: This script installs Gitleaks."
    echo "========================================"
}

# Function to check for sudo access
check_sudo() {
    echo "========================================"
    echo " Checking for sudo permissions..."
    echo "========================================"
    if sudo -n true 2>/dev/null; then
        echo "Sudo access confirmed."
    else
        echo "Sudo access is required but not available. Please run the script with sudo."
        exit 1
    fi
}

# Function to install Gitleaks
install_gitleaks() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$ARCH" in
        aarch64) ARCH="arm64" ;;
        x86_64) ARCH="x64" ;;
    esac

    echo "========================================"
    echo " Installing Gitleaks for $OS-$ARCH"
    echo "========================================"
    echo $ARCH $OS
    LATEST_RELEASE_DATA=$(curl -sL https://api.github.com/repos/zricethezav/gitleaks/releases/latest)
    download_url=$(echo "$LATEST_RELEASE_DATA" | grep "browser_download_url.*${OS}.*${ARCH}" | cut -d '"' -f 4 | head -n 1)

    if [ -z "$download_url" ]; then
        echo "Failed to find a download link for Gitleaks."
        exit 1
    fi

    filename=$(basename "$download_url")
    wget -O "$filename" "$download_url" || { echo "Failed to download Gitleaks."; exit 1; }

    tar -xvf "$filename" -C /usr/local/bin/ || { echo "Failed to extract Gitleaks."; exit 1; }

    chmod +x /usr/local/bin/gitleaks || { echo "Failed to set execute permissions for Gitleaks."; exit 1; }

    command -v gitleaks > /dev/null || { echo "Gitleaks installation failed."; exit 1; }

    echo "Gitleaks successfully installed!"
    rm "$filename"
}

# Function to install pre-commit
install_pre_commit() {
    echo "========================================"
    echo " Installing pre-commit..."
    echo "========================================"

    if ! command -v pip > /dev/null; then
        echo "pip is not installed. Attempting to install pip..."
        sudo apt-get install -y python3-pip || { echo "Failed to install pip."; exit 1; }
    fi

    pip install pre-commit || { echo "Failed to install pre-commit."; exit 1; }

    echo "pre-commit successfully installed."
    pre-commit --version
}

# Function to set up pre-commit
setting_pre_commit() {
    echo "========================================"
    echo "Setting up pre-commit..."
    echo "========================================"

    if ! command -v pre-commit > /dev/null; then
        echo "pre-commit is not installed. Exiting."
        exit 1
    fi

    if ! command -v git > /dev/null; then
        echo "git is not installed. Exiting."
        exit 1
    fi

    if [ ! -d .git ]; then
        echo "No .git directory found. Provide path to your git repo:"
        read -r git_path
        cd "$git_path" || { echo "Invalid path. Exiting."; exit 1; }

        [ -d .git ] || { echo "Invalid path. Exiting."; exit 1; }
    fi

    echo "========================================"
    echo "Install Gitleaks script"
    echo "========================================"
    cat << 'EOF' > .git/hooks/gitleaks.sh
#!/bin/bash

# get status gitleaks з git config
gitleaksEnabled=$(git config --get gitleaks.enable)

if [ "$gitleaksEnabled" = "false" ]; then
    echo "Gitleaks check is disabled"
    exit 0
fi

# Save staged changes and index to a temporary stash working directory
git stash save -q --keep-index

# Run gitleaks on whole repo
gitleaksResult=$(gitleaks detect --source="." --verbose)

# 
git stash pop -q

# Check if gitleaks detected any secrets
if [ -n "$gitleaksResult" ]; then
    echo "Gitleaks detected secrets in staged files"
    echo "$gitleaksResult"
    exit 1
fi

EOF

    chmod +x .git/hooks/gitleaks.sh
}

# Function to set up Gitleaks config
setting_gitleaks_config() {
    echo "========================================"
    echo "Setting up Gitleaks config..."
    echo "========================================"
    cat << EOF > .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.16.1
    hooks:
      - id: gitleaks
        entry: bash -c '.git/hooks/gitleaks.sh'
        language: system
EOF

    echo ".pre-commit-config.yaml has been configured."
    pre-commit install
    git config --local gitleaks.enable true
}

# Run functions
check_sudo
print_header
install_gitleaks
install_pre_commit
setting_pre_commit
setting_gitleaks_config
