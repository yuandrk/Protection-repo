#!/bin/bash

# Author: Yurii Andriuk
# Date Created: 01-01-24
# Description: Gitleaks installation script
# Version: 1.0.2
# License: GNU General Public License (GPL)

# Main script
echo "Gitleaks installation script"
echo "Version 1.0.1"
echo "Author: Yurii Andriuk"
echo "yurii.andriuk@gmail.com" 
echo "Date Created: 01-01-24"
echo "Description: Gitleaks installation script"


############################################################
#                            Help                          #
############################################################
# Help()
# {
#    # Display Help
#    echo "Add description of the script functions here."
#    echo
#    echo "Syntax: scriptTemplate [-g|h|v|V]"
#    echo "options:"
#    echo "g     Print the GPL license notification."
#    echo "h     Print this Help."
#    echo "v     Verbose mode."
#    echo "V     Print software version and exit."
#    echo
# }

############################################################
############################################################
#                    Main program                          #
############################################################
############################################################

# Function to check for sudo access
check_sudo() {
    # Print a message to let the user know what's happening
    echo "Checking for sudo permissions..."

    # The 'true' command does nothing and always succeeds.
    # We use it here to check if the user can execute commands with sudo.
    if sudo -n true 2>/dev/null; then
        # If the 'sudo -n true' command succeeds, the user has sudo access.
        echo "Sudo access confirmed."
    else
        # If the 'sudo -n true' command fails, the user does not have sudo access.
        echo "Sudo access is required but not available. Please run the script with sudo."
        exit 1
    fi
}

# Function to install Gitleaks
install_gitleaks() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    # Adjusting for ARM64 architecture
    if [ "$arch" == "aarch64" ]; then
        arch="arm64"
    fi

    # Adjusting for x86_64 architecture   
    if [ "$arch" == "x86_64" ]; then
         arch="x64"
    fi  

    echo "Installing Gitleaks for $os-$arch..."

    # Download the latest version of Gitleaks
    local download_url=$(curl -sL https://api.github.com/repos/zricethezav/gitleaks/releases/latest | grep -oP "https://[^ \"]*(${os}.*${arch})[^ \"]*" | cut -d '"' -f 1)
    
    if [ -z "$download_url" ]; then
        echo "Failed to find a download link for Gitleaks."
        exit 1
    fi

    echo "Download URL found: $download_url"
    local filename=$(basename "$download_url")
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
}


# Function to install pre-commit
install_pre_commit() {
    echo "Installing pre-commit..."

    # Check if pip is installed
    if ! command -v pip > /dev/null; then
        echo "pip is not installed. Attempting to install pip..."
        # Install pip (Python's package installer)
        if ! sudo apt-get install -y python3-pip; then
            echo "Failed to install pip. Exiting."
            return 1
        fi
    fi

    # Install pre-commit using pip
    if ! pip install pre-commit; then
        echo "Failed to install pre-commit. Exiting."
        return 1
    fi
    pre-commit --version 
    echo "pre-commit successfully installed."
}

setting_pre_commit() {
    echo "Setting up pre-commit..."

    # Check if pre-commit is installed
    if ! command -v pre-commit > /dev/null; then
        echo "pre-commit is not installed. Exiting."
        return 1
    fi

    # Check if git is installed
    if ! command -v git > /dev/null; then
        echo "git is not installed. Exiting."
        return 1
    fi

    # Check if .git directory exists
    if [ ! -d .git ]; then
        echo "No .git directory found."
        echo "Provide path to your git repo:"
        read -r git_path
        cd "$git_path" || return 1  # Exit if the cd command fails

        if [ ! -d .git ]; then
            echo "Invalid path. Exiting."
            return 1
        fi
    fi

    echo "Install Gitleaks script"
    cat << EOF > .git/hooks/gitleaks.sh
#!/bin/bash

# Getting status from git config
gitleaksEnabled=$(git config --get gitleaks.enable)

if [ "$gitleaksEnabled" = "false" ]; then
    echo "Gitleaks check is disabled"
    exit 0
fi

# Rub gitleaks
gitleaks detect -v 

EOF 

chmod +x .git/hooks/gitleaks.sh

}

setting_gitleaks_config() {
    echo "Setting up Gitleaks config..."
    # Write configuration to .pre-commit-config.yaml
    echo "Writing configuration to .pre-commit-config.yaml..."
    cat << EOF > .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.16.1
    hooks:
      - id: gitleaks
        name: Gitleaks config
        entry: bash -c '.git/hooks/gitleaks.sh'
        language: system
EOF

    echo ".pre-commit-config.yaml has been configured."
    pre-commit install
}
# First, check for sudo permissions
check_sudo

# Run the installation function
# install_gitleaks

# Run the installation function
# install_pre_commit

# Run the function
setting_pre_commit

setting_gitleaks_config


############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
# while getopts ":hn:" option; do
#    case $option in
#       h) # display Help
#          Help
#          exit;;
#       n) # Enter a name
#          Name=$OPTARG;;
#      \?) # Invalid option
#          echo "Error: Invalid option"
#          exit;;
#    esac
# done