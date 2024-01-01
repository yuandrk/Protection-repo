#!/bin/sh

# Author: Yurii Andriuk
# Date Created: 01-01-24
# Description: Gitleaks installation script
# Version: 1.0.2
# License: GNU General Public License (GPL)

# Print header function
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

############################################################
############################################################
#                    Main program                          #
############################################################
############################################################

# Function to check for sudo access
check_sudo() {
    echo "========================================"
    echo " Checking for sudo permissions..."
    echo "========================================"
    # The 'true' command does nothing and always succeeds.
    # We use it here to check if the user can execute commands with sudo.
    if sudo -n true 2>/dev/null; then
        echo "Sudo access confirmed."
    else
        echo "Sudo access is required but not available. Please run the script with sudo."
        exit 1
    fi
}

# Function to install Gitleaks
install_gitleaks() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    case "$arch" in
        "aarch64") arch="arm64" ;;
        "x86_64") arch="x64" ;;
    esac

    echo "========================================"
    echo " Installing Gitleaks for $os-$arch...."
    echo "========================================"
    # Download the latest version of Gitleaks
    download_url=$(curl -sL https://api.github.com/repos/zricethezav/gitleaks/releases/latest | grep -o "https://[^ \"]*(${os}.*${arch})[^ \"]*" | cut -d '"' -f 1)
    
    if [ -z "$download_url" ]; then
        echo "Failed to find a download link for Gitleaks."
        exit 1
    fi

    echo "Download URL found: $download_url"
    filename=$(basename "$download_url")
    echo "Downloading $filename..."

    if ! wget -O "$filename" "$download_url"; then
        echo "Failed to download Gitleaks."
        exit 1
    fi

    echo "Extracting $filename to /usr/local/bin/..."
    if ! tar -xvf "$filename" -C /usr/local/bin/; then
        echo "Failed to extract Gitleaks."
        exit 1
    fi

    if ! chmod +x /usr/local/bin/gitleaks; then
        echo "Failed to set execute permissions for Gitleaks."
        exit 1
    fi

    if ! command -v gitleaks > /dev/null; then
        echo "Gitleaks installation failed."
        exit 1
    fi

    echo "Gitleaks successfully installed!"
    rm "$filename"
}

# ... Rest of the functions (install_pre_commit, setting_pre_commit, setting_gitleaks_config) ...

# First, check for sudo permissions
check_sudo

# Print the header
print_header

# Run the installation function
install_gitleaks

# Run the installation function
install_pre_commit

# Run the function
setting_pre_commit

# Setting Gitleaks config 
setting_gitleaks_config
