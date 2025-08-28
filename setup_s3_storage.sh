#!/bin/bash

# Simple AWS S3 Environment Variables Setup Script
# This script prompts for AWS credentials and makes them persistent

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "AWS S3 Environment Variables Setup"
echo ""

# Prompt for AWS Access Key ID
while [[ -z "${AWS_ACCESS_KEY_ID}" ]]; do
    read -p "AWS Access Key ID: " -s AWS_ACCESS_KEY_ID
    echo ""
    if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
        print_error "AWS Access Key ID is required. Please try again."
    fi
done

# Prompt for AWS Secret Access Key
while [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; do
    read -p "AWS Secret Access Key: " -s AWS_SECRET_ACCESS_KEY
    echo ""
    if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
        print_error "AWS Secret Access Key is required. Please try again."
    fi
done

# Prompt for S3 Bucket
while [[ -z "${AWS_S3_BUCKET}" ]]; do
    read -p "S3 Bucket Name: " AWS_S3_BUCKET
    if [[ -z "${AWS_S3_BUCKET}" ]]; then
        print_error "S3 Bucket Name is required. Please try again."
    fi
done

# Prompt for AWS Region (default to us-east-1)
read -p "AWS Region (default: us-east-1): " AWS_REGION
AWS_REGION="${AWS_REGION:-us-east-1}"

echo ""
print_success "Configuration collected!"
echo ""
print_status "Configuration Summary:"
echo "  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:8}..."
echo "  AWS_SECRET_ACCESS_KEY: [HIDDEN]"
echo "  AWS_S3_BUCKET: ${AWS_S3_BUCKET}"
echo "  AWS_REGION: ${AWS_REGION}"
echo ""

# Confirm configuration
read -p "Is this configuration correct? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_error "Configuration cancelled."
    exit 1
fi

echo ""

# Export variables to current session
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_S3_BUCKET
export AWS_REGION

print_success "Environment variables exported to current session!"

# Determine shell configuration file
shell_config=""
if [[ -n "$ZSH_VERSION" ]]; then
    shell_config="$HOME/.zshrc"
    print_status "Detected Zsh shell, using $shell_config"
elif [[ -n "$BASH_VERSION" ]]; then
    shell_config="$HOME/.bashrc"
    print_status "Detected Bash shell, using $shell_config"
else
    # Try to detect shell config file
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
        print_status "Detected .zshrc file, using $shell_config"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
        print_status "Detected .bashrc file, using $shell_config"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        shell_config="$HOME/.bash_profile"
        print_status "Detected .bash_profile file, using $shell_config"
    else
        print_warning "Could not determine shell configuration file."
        print_status "Please manually add the following to your shell config:"
        echo ""
        echo "# AWS S3 Configuration"
        echo "export AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}'"
        echo "export AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}'"
        echo "export AWS_S3_BUCKET='${AWS_S3_BUCKET}'"
        echo "export AWS_REGION='${AWS_REGION}'"
        echo ""
        exit 0
    fi
fi

# Check if variables are already in the config file
if grep -q "AWS_ACCESS_KEY_ID" "$shell_config"; then
    print_warning "AWS environment variables already exist in $shell_config"
    print_status "Updating existing variables..."
    
    # Remove existing AWS variables
    sed -i.bak '/^export AWS_/d' "$shell_config"
fi

# Add AWS configuration to shell config file
cat >> "$shell_config" << EOF

# AWS S3 Configuration
export AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}'
export AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}'
export AWS_S3_BUCKET='${AWS_S3_BUCKET}'
export AWS_REGION='${AWS_REGION}'
EOF

print_success "Environment variables added to $shell_config"

# Create a temporary script to source the config file
temp_script=$(mktemp)
cat > "$temp_script" << 'EOF'
#!/bin/bash
# Temporary script to source shell config and export variables
source "$1"
echo "Environment variables loaded successfully!"
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_S3_BUCKET: $AWS_S3_BUCKET"
echo "AWS_REGION: $AWS_REGION"
EOF

chmod +x "$temp_script"

# Source the shell config file to load variables into current session
print_status "Loading environment variables into current session..."
if source "$shell_config"; then
    print_success "Environment variables are now active in this session!"
else
    print_warning "Could not source $shell_config directly. Variables will be available in new terminal sessions."
fi

# Clean up temp script
rm -f "$temp_script"

echo ""
print_success "Setup completed successfully!"
echo ""
print_status "Environment variables are now persistent:"
echo "  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:8}..."
echo "  AWS_SECRET_ACCESS_KEY: [HIDDEN]"
echo "  AWS_S3_BUCKET: ${AWS_S3_BUCKET}"
echo "  AWS_REGION: ${AWS_REGION}"
echo ""
print_status "To verify, run:"
echo "  echo \$AWS_ACCESS_KEY_ID"
echo "  echo \$AWS_S3_BUCKET"
echo ""
print_warning "Note: The variables will be available in new terminal sessions automatically."
print_status "If variables are not available in current session, run: source $shell_config"
