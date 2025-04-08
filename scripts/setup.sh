#!/bin/bash
# Setup script for the DAB ETL Framework
# This script helps with setting up the GitHub repository and configuring the Databricks workspaces

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  DAB ETL Framework Setup Script        ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if the Databricks CLI is installed
if ! command -v databricks &> /dev/null; then
    echo -e "${RED}Error: Databricks CLI is not installed.${NC}"
    echo -e "Please install it using: pip install databricks-cli"
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed.${NC}"
    echo -e "Please install Git before continuing."
    exit 1
fi

# Function to prompt for input with a default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    
    echo -e -n "${YELLOW}$prompt [${default}]: ${NC}"
    read input
    echo "${input:-$default}"
}

# Step 1: Configure GitHub repository
echo -e "${GREEN}Step 1: Configure GitHub Repository${NC}"
echo -e "This step will help you set up the GitHub repository for the DAB ETL Framework."
echo ""

# Get GitHub repository information
GITHUB_USERNAME=$(prompt_with_default "Enter your GitHub username" "yourusername")
GITHUB_REPO=$(prompt_with_default "Enter the repository name" "dab-etl-framework")
GITHUB_TOKEN=$(prompt_with_default "Enter your GitHub Personal Access Token (optional)" "")

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit"
    
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "Setting up remote repository..."
        git remote add origin https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git
        git push -u origin main
    else
        echo "No GitHub token provided. You'll need to set up the remote repository manually."
        echo "Use the following commands:"
        echo "  git remote add origin https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"
        echo "  git push -u origin main"
    fi
else
    echo "Git repository already initialized."
fi

echo ""

# Step 2: Configure Databricks workspaces
echo -e "${GREEN}Step 2: Configure Databricks Workspaces${NC}"
echo -e "This step will help you configure the Databricks workspaces for the DAB ETL Framework."
echo ""

# Get Databricks workspace information
DEV_WORKSPACE=$(prompt_with_default "Enter your development workspace URL" "https://adb-3926792307180734.14.azuredatabricks.net")
DEV_TOKEN=$(prompt_with_default "Enter your development workspace access token" "")

TEST_WORKSPACE=$(prompt_with_default "Enter your test workspace URL" "https://adb-1664798693105110.10.azuredatabricks.net")
TEST_TOKEN=$(prompt_with_default "Enter your test workspace access token" "")

PROD_WORKSPACE=$(prompt_with_default "Enter your production workspace URL" "https://adb-2946519586949099.19.azuredatabricks.net")
PROD_TOKEN=$(prompt_with_default "Enter your production workspace access token" "")

# Update databricks.yml with the workspace information
echo "Updating databricks.yml with workspace information..."
sed -i.bak "s|https://adb-3926792307180734.14.azuredatabricks.net|${DEV_WORKSPACE}|g" databricks.yml
sed -i.bak "s|https://adb-1664798693105110.10.azuredatabricks.net|${TEST_WORKSPACE}|g" databricks.yml
sed -i.bak "s|https://adb-2946519586949099.19.azuredatabricks.net|${PROD_WORKSPACE}|g" databricks.yml
rm databricks.yml.bak

# Configure Databricks CLI profiles
echo "Configuring Databricks CLI profiles..."
databricks configure --token --profile dev --host "${DEV_WORKSPACE}" --token "${DEV_TOKEN}"
databricks configure --token --profile test --host "${TEST_WORKSPACE}" --token "${TEST_TOKEN}"
databricks configure --token --profile prod --host "${PROD_WORKSPACE}" --token "${PROD_TOKEN}"

echo ""

# Step 3: Set up GitHub Actions secrets
echo -e "${GREEN}Step 3: Set up GitHub Actions Secrets${NC}"
echo -e "To enable CI/CD with GitHub Actions, you need to set up the following secrets in your GitHub repository:"
echo ""
echo -e "${YELLOW}DATABRICKS_HOST_DEV:${NC} ${DEV_WORKSPACE}"
echo -e "${YELLOW}DATABRICKS_TOKEN_DEV:${NC} ${DEV_TOKEN}"
echo -e "${YELLOW}DATABRICKS_HOST_TEST:${NC} ${TEST_WORKSPACE}"
echo -e "${YELLOW}DATABRICKS_TOKEN_TEST:${NC} ${TEST_TOKEN}"
echo -e "${YELLOW}DATABRICKS_HOST_PROD:${NC} ${PROD_WORKSPACE}"
echo -e "${YELLOW}DATABRICKS_TOKEN_PROD:${NC} ${PROD_TOKEN}"
echo ""
echo -e "You can set these secrets in your GitHub repository at:"
echo -e "https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}/settings/secrets/actions"
echo ""

# Step 4: Validate and deploy the bundle
echo -e "${GREEN}Step 4: Validate and Deploy the Bundle${NC}"
echo -e "Would you like to validate and deploy the bundle to your development workspace now?"
echo -e -n "${YELLOW}[y/N]: ${NC}"
read DEPLOY

if [[ $DEPLOY =~ ^[Yy]$ ]]; then
    echo "Validating bundle..."
    databricks bundle validate
    
    if [ $? -eq 0 ]; then
        echo "Deploying bundle to development workspace..."
        databricks bundle deploy --target development
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Bundle deployed successfully!${NC}"
        else
            echo -e "${RED}Failed to deploy bundle.${NC}"
        fi
    else
        echo -e "${RED}Bundle validation failed.${NC}"
    fi
else
    echo "Skipping bundle validation and deployment."
fi

echo ""

# Completion
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Setup Complete!                       ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "The DAB ETL Framework has been set up successfully."
echo -e "You can now start using the framework to build and deploy ETL pipelines."
echo ""
echo -e "Next steps:"
echo -e "1. Push your code to GitHub (if not done automatically)"
echo -e "2. Set up GitHub Actions secrets"
echo -e "3. Customize the framework for your specific use case"
echo -e "4. Deploy the bundle to your Databricks workspaces"
echo ""
echo -e "For more information, refer to the README.md file."
echo ""
