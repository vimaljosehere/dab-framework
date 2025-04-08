#!/bin/bash
# Simple script to push the DAB ETL Framework to GitHub

set -e
set -x

# GitHub repository information
GITHUB_REPO="https://github.com/vimaljosehere/dab-framework"
# Use environment variable or prompt for token if not set
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "GitHub token not found in environment."
    echo -n "Enter your GitHub token: "
    read -s GITHUB_TOKEN
    echo ""
    if [ -z "${GITHUB_TOKEN}" ]; then
        echo "Error: GitHub token is required."
        exit 1
    fi
fi

# Check if we're in the right directory
if [ ! -f "databricks.yml" ]; then
    echo "Error: databricks.yml not found."
    echo "Please run this script from the root of the DAB ETL Framework directory."
    exit 1
fi

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
fi

# Add all files to Git
echo "Adding files to Git..."
git add .

# Commit changes
echo "Committing changes..."
git commit -m "Initial commit of DAB ETL Framework" || echo "No changes to commit"

# Add remote repository
echo "Adding remote repository..."
git remote add origin https://${GITHUB_TOKEN}@github.com/vimaljosehere/dab-framework.git || git remote set-url origin https://${GITHUB_TOKEN}@github.com/vimaljosehere/dab-framework.git

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main || git push -u origin master

echo "Successfully pushed DAB ETL Framework to GitHub!"
echo "Repository URL: ${GITHUB_REPO}"
