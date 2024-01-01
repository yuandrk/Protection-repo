# Gitleaks Installation Script

## Overview

This repository hosts a Bash script (`protection.sh`) designed for the installation of Gitleaks. Gitleaks is a robust, open-source tool that helps in detecting and preventing sensitive data leaks in your Git repositories. This script simplifies the process of installing Gitleaks, making it more accessible for integration into various DevOps workflows.

## Description

The `protection.sh` script automates the installation process of Gitleaks. It ensures a hassle-free setup, allowing you to quickly deploy Gitleaks in your development environment. By using this script, you can enhance the security of your source code repositories by easily identifying any accidental leaks of sensitive information.

## Installation

### Standard Installation

1. Download the `protection.sh` script from this repository.
2. Give execute permission to the script:
    
    ```bash
    chmod +x protection.sh
    ```
    
3. Run the script:
    
    ```bash
    sudo ./protection.sh
    ```
    

### Installation Using Curl

You can also install the script directly using `curl` and `sh`:

```bash 
curl -sSL https://raw.githubusercontent.com/yuandrk/Protection-repo/main/protection.sh | sudo sh
```

**Important:** Always review the script's contents before executing with `sudo`.

## Gitleaks Configuration with Git

After installing Gitleaks, you can configure it within your local Git repository to enable or disable its features.

* To enable Gitleaks in your repository:
    
    ```bash
    git config --local gitleaks.enable true
    ```
    
    This command activates Gitleaks checks for your local repository, ensuring that any commits you make are scanned for potential leaks.
    
* To disable Gitleaks:
    
    ```bash
    git config --local gitleaks.enable false
    ```
    
    Use this command if you need to temporarily disable Gitleaks scanning for your repository. It's useful in cases where you are working with data that you know is safe, or when performing tasks where the additional scanning is not needed.
    

**Note:** Configuring Gitleaks with `git config` allows for flexible control over its operation on a per-repository basis. This can be particularly useful in complex projects or workflows where different security measures are required for different parts of the code.

## Usage

Once Gitleaks is installed and configured, it will scan your commits for sensitive information. For detailed usage instructions, refer to the Gitleaks GitHub page.