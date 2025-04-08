#!/bin/bash
# Script to set up the Databricks CLI for the DAB ETL Framework

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Set up Databricks CLI                 ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo -e "${RED}Error: Python is not installed.${NC}"
    echo -e "Please install Python before continuing."
    exit 1
fi

# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo -e "${RED}Error: pip is not installed.${NC}"
    echo -e "Please install pip before continuing."
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

# Install Databricks CLI
echo -e "${GREEN}Installing Databricks CLI...${NC}"
pip install databricks-cli

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install Databricks CLI.${NC}"
    exit 1
fi

# Install Databricks SDK
echo -e "${GREEN}Installing Databricks SDK...${NC}"
pip install -U databricks-sdk

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install Databricks SDK.${NC}"
    exit 1
fi

# Configure Databricks CLI profiles
echo -e "${GREEN}Configuring Databricks CLI profiles...${NC}"
echo ""

# Development profile
echo -e "${GREEN}Development profile${NC}"
DEV_WORKSPACE=$(prompt_with_default "Enter development workspace URL" "https://adb-3926792307180734.14.azuredatabricks.net")
DEV_TOKEN=$(prompt_with_default "Enter development workspace access token" "")

echo "Configuring development profile..."
databricks configure --token --profile dev --host "${DEV_WORKSPACE}" --token "${DEV_TOKEN}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to configure development profile.${NC}"
    exit 1
fi

# Test profile
echo -e "${GREEN}Test profile${NC}"
TEST_WORKSPACE=$(prompt_with_default "Enter test workspace URL" "https://adb-1664798693105110.10.azuredatabricks.net")
TEST_TOKEN=$(prompt_with_default "Enter test workspace access token" "")

echo "Configuring test profile..."
databricks configure --token --profile test --host "${TEST_WORKSPACE}" --token "${TEST_TOKEN}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to configure test profile.${NC}"
    exit 1
fi

# Production profile
echo -e "${GREEN}Production profile${NC}"
PROD_WORKSPACE=$(prompt_with_default "Enter production workspace URL" "https://adb-2946519586949099.19.azuredatabricks.net")
PROD_TOKEN=$(prompt_with_default "Enter production workspace access token" "")

echo "Configuring production profile..."
databricks configure --token --profile prod --host "${PROD_WORKSPACE}" --token "${PROD_TOKEN}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to configure production profile.${NC}"
    exit 1
fi

# Test the connection
echo -e "${GREEN}Testing the connection...${NC}"
echo ""

echo "Testing development profile..."
databricks --profile dev workspace ls /

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to connect to development workspace.${NC}"
    echo -e "Please check your workspace URL and access token."
else
    echo -e "${GREEN}Successfully connected to development workspace!${NC}"
fi

echo "Testing test profile..."
databricks --profile test workspace ls /

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to connect to test workspace.${NC}"
    echo -e "Please check your workspace URL and access token."
else
    echo -e "${GREEN}Successfully connected to test workspace!${NC}"
fi

echo "Testing production profile..."
databricks --profile prod workspace ls /

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to connect to production workspace.${NC}"
    echo -e "Please check your workspace URL and access token."
else
    echo -e "${GREEN}Successfully connected to production workspace!${NC}"
fi

# Success
echo ""
echo -e "${GREEN}Databricks CLI setup complete!${NC}"
echo ""
echo -e "You can now use the Databricks CLI to interact with your Databricks workspaces."
echo -e "For example:"
echo -e "  databricks --profile dev workspace ls /"
echo -e "  databricks --profile test workspace ls /"
echo -e "  databricks --profile prod workspace ls /"
echo ""
echo -e "Next steps:"
echo -e "1. Run the setup.sh script to set up the DAB ETL Framework"
echo -e "2. Deploy the framework to your Databricks workspaces"
echo -e "3. Run the DLT pipeline"
echo ""
echo -e "For more information, refer to the README.md file."
echo ""
