#!/bin/bash
set -e  # Exit on any error

# Function to check command existence
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed or not in PATH"
        return 1
    fi
}

# Function to cleanup temporary files
cleanup() {
    echo "* Cleaning up temporary files..."
    rm -rf aws awscliv2.zip
}

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "* AWS credentials not found in environment. Skipping AWS CLI installation."
    exit 0
fi

# Install prerequisites
echo "* Installing prerequisites..."
if [ -f /etc/debian_version ]; then
    sudo apt-get update && sudo apt-get install -y curl unzip
fi

# Set AWS CLI version
AWS_CLI_VERSION="2.13.26"  # Pin to specific version for consistency

if command -v aws >/dev/null 2>&1 && aws --version | grep -q 'aws-cli/2'; then
    INSTALLED_VERSION=$(aws --version | cut -d/ -f2 | cut -d' ' -f1)
    echo "* AWS CLI v${INSTALLED_VERSION} is already installed."
    if [[ "${INSTALLED_VERSION}" == "${AWS_CLI_VERSION}" ]]; then
        echo "* Version matches required version. Skipping installation."
    else
        echo "* Updating AWS CLI to version ${AWS_CLI_VERSION}..."
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install --update
    fi
else
    echo "* Installing AWS CLI v${AWS_CLI_VERSION}..."
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
fi

# Verify AWS CLI installation
if ! check_command aws; then
    echo "Error: AWS CLI installation failed"
    exit 1
fi

# Configure AWS CLI
AWS_CONFIG_DIR="/home/vagrant/.aws"
if [[ ! -f "${AWS_CONFIG_DIR}/config" || ! -f "${AWS_CONFIG_DIR}/credentials" ]]; then
    echo "* Configuring AWS CLI..."
    mkdir -p "${AWS_CONFIG_DIR}"
    chmod 700 "${AWS_CONFIG_DIR}"

    # Configure credentials with error checking
    if ! aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"; then
        echo "Error: Failed to set AWS access key"
        exit 1
    fi

    if ! aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"; then
        echo "Error: Failed to set AWS secret key"
        exit 1
    fi

    # Set region with fallback
    AWS_REGION="${AWS_DEFAULT_REGION:-eu-central-1}"
    if ! aws configure set region "$AWS_REGION"; then
        echo "Error: Failed to set AWS region"
        exit 1
    fi

    # Set output format with fallback
    AWS_OUTPUT="${AWS_OUTPUT_FORMAT:-json}"
    if ! aws configure set output "$AWS_OUTPUT"; then
        echo "Error: Failed to set AWS output format"
        exit 1
    fi

    echo "* AWS CLI configuration:"
    aws configure list
else
    echo "* AWS CLI is already configured. Checking configuration..."
    if ! aws configure list &>/dev/null; then
        echo "Warning: Existing AWS configuration might be invalid"
    fi
fi

# Set up autocomplete
BASHRC="/home/vagrant/.bashrc"
if ! grep -q "complete -C $(which aws_completer) aws" "$BASHRC"; then
    echo '* Enabling AWS CLI autocomplete...'
    echo "complete -C $(which aws_completer) aws" >> "$BASHRC"
    echo "* Autocomplete enabled successfully"
else
    echo "* Autocomplete already enabled"
fi

# Verify AWS credentials work
echo "* Verifying AWS credentials..."
if ! aws sts get-caller-identity &>/dev/null; then
    echo "Warning: AWS credentials validation failed. Please verify your credentials manually."
else
    echo "* AWS credentials verified successfully"
fi

echo "* AWS CLI installation and configuration completed successfully"
