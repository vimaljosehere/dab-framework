#!/bin/bash
# Script to deploy the DAB ETL Framework to Databricks workspaces

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Deploy DAB ETL Framework to Databricks ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if the Databricks CLI is installed
if ! command -v databricks &> /dev/null; then
    echo -e "${RED}Error: Databricks CLI is not installed.${NC}"
    echo -e "Please install it using: pip install databricks-cli"
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

# Check if we're in the right directory
if [ ! -f "databricks.yml" ]; then
    echo -e "${RED}Error: databricks.yml not found.${NC}"
    echo -e "Please run this script from the root of the DAB ETL Framework directory."
    exit 1
fi

# Get target environment
echo -e "${GREEN}Select target environment:${NC}"
echo -e "1. Development"
echo -e "2. Test"
echo -e "3. Production"
echo -e -n "${YELLOW}Enter your choice [1]: ${NC}"
read choice

case $choice in
    1|"")
        TARGET="development"
        ;;
    2)
        TARGET="test"
        ;;
    3)
        TARGET="production"
        ;;
    *)
        echo -e "${RED}Invalid choice. Using development as default.${NC}"
        TARGET="development"
        ;;
esac

echo -e "Selected target: ${GREEN}${TARGET}${NC}"
echo ""

# Configure Databricks CLI profile
echo -e "${GREEN}Configure Databricks CLI profile for ${TARGET}${NC}"
echo ""

# Use environment variables if set, otherwise prompt
DEFAULT_WORKSPACE_URL=""
DEFAULT_TOKEN=""

# Set default values based on target environment
if [ "${TARGET}" == "development" ]; then
    DEFAULT_WORKSPACE_URL="https://adb-3926792307180734.14.azuredatabricks.net"
    # Do not set default token, will prompt if not in environment
elif [ "${TARGET}" == "test" ]; then
    DEFAULT_WORKSPACE_URL="https://adb-1664798693105110.10.azuredatabricks.net"
    # Do not set default token, will prompt if not in environment
elif [ "${TARGET}" == "production" ]; then
    DEFAULT_WORKSPACE_URL="https://adb-2946519586949099.19.azuredatabricks.net"
    # Do not set default token, will prompt if not in environment
fi

# Use environment variables if set
if [ -n "${DATABRICKS_HOST}" ]; then
    WORKSPACE_URL="${DATABRICKS_HOST}"
else
    WORKSPACE_URL=$(prompt_with_default "Enter Databricks workspace URL" "${DEFAULT_WORKSPACE_URL}")
fi

if [ -n "${DATABRICKS_TOKEN}" ]; then
    TOKEN="${DATABRICKS_TOKEN}"
else
    TOKEN=$(prompt_with_default "Enter Databricks access token" "${DEFAULT_TOKEN}")
fi

echo "Configuring Databricks CLI profile..."
databricks configure --token --profile ${TARGET} --host "${WORKSPACE_URL}" --token "${TOKEN}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to configure Databricks CLI profile.${NC}"
    exit 1
fi

# Validate the bundle
echo "Validating bundle..."
databricks bundle validate

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Bundle validation failed.${NC}"
    exit 1
fi

# Deploy the bundle
echo "Deploying bundle to ${TARGET}..."
databricks bundle deploy --target ${TARGET}

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Bundle deployment failed.${NC}"
    exit 1
fi

# Success
echo -e "${GREEN}Successfully deployed DAB ETL Framework to ${TARGET}!${NC}"
echo ""
echo -e "Next steps:"
echo -e "1. Run the DLT pipeline in the Databricks workspace"
echo -e "2. Monitor the pipeline execution"
echo -e "3. Explore the data in the bronze, silver, and gold tables"
echo ""
echo -e "For more information, refer to the README.md file."
echo ""
