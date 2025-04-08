#!/bin/bash
# Script to push the DAB ETL Framework to the GitHub repository

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Push DAB ETL Framework to GitHub      ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed.${NC}"
    echo -e "Please install Git before continuing."
    exit 1
fi

# GitHub repository information
GITHUB_REPO="https://github.com/vimaljosehere/dab-framework"
# Use environment variable or prompt for token if not set
if [ -z "${GITHUB_TOKEN}" ]; then
    echo -e "${YELLOW}GitHub token not found in environment.${NC}"
    echo -e -n "${YELLOW}Enter your GitHub token: ${NC}"
    read -s GITHUB_TOKEN
    echo ""
    if [ -z "${GITHUB_TOKEN}" ]; then
        echo -e "${RED}Error: GitHub token is required.${NC}"
        exit 1
    fi
fi

# Check if we're in the right directory
if [ ! -f "databricks.yml" ]; then
    echo -e "${RED}Error: databricks.yml not found.${NC}"
    echo -e "Please run this script from the root of the DAB ETL Framework directory."
    exit 1
fi

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to initialize Git repository.${NC}"
        exit 1
    fi
else
    echo "Git repository already initialized."
fi

# Add all files to Git
echo "Adding files to Git..."
git add .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to add files to Git.${NC}"
    exit 1
fi

# Commit changes
echo "Committing changes..."
git commit -m "Initial commit of DAB ETL Framework"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to commit changes.${NC}"
    exit 1
fi

# Add remote repository
echo "Adding remote repository..."
git remote add origin https://${GITHUB_TOKEN}@github.com/vimaljosehere/dab-framework.git

if [ $? -ne 0 ]; then
    # Check if remote already exists
    if git remote | grep -q "^origin$"; then
        echo "Remote 'origin' already exists. Updating URL..."
        git remote set-url origin https://${GITHUB_TOKEN}@github.com/vimaljosehere/dab-framework.git
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to update remote URL.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: Failed to add remote repository.${NC}"
        exit 1
    fi
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

if [ $? -ne 0 ]; then
    # Try pushing to master branch if main fails
    echo "Pushing to main branch failed. Trying master branch..."
    git push -u origin master
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to push to GitHub.${NC}"
        echo -e "You may need to manually push using:"
        echo -e "  git push -u origin main"
        exit 1
    fi
fi

# Success
echo -e "${GREEN}Successfully pushed DAB ETL Framework to GitHub!${NC}"
echo -e "Repository URL: ${GITHUB_REPO}"
echo ""
echo -e "Next steps:"
echo -e "1. Set up GitHub Actions secrets for CI/CD"
echo -e "2. Configure Databricks workspaces"
echo -e "3. Deploy the bundle to your Databricks workspaces"
echo ""
echo -e "For more information, refer to the README.md file."
echo ""
