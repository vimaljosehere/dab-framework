#!/bin/bash
# Script to run tests for the DAB ETL Framework

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Run Tests for DAB ETL Framework       ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -d "tests" ]; then
    echo -e "${RED}Error: tests directory not found.${NC}"
    echo -e "Please run this script from the root of the DAB ETL Framework directory."
    exit 1
fi

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo -e "${RED}Error: Python is not installed.${NC}"
    echo -e "Please install Python before continuing."
    exit 1
fi

# Check if pytest is installed
if ! python -c "import pytest" &> /dev/null; then
    echo -e "${YELLOW}Warning: pytest is not installed.${NC}"
    echo -e "Installing pytest..."
    pip install pytest
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to install pytest.${NC}"
        exit 1
    fi
fi

# Run tests
echo -e "${GREEN}Running tests...${NC}"
echo ""

# Option to run specific tests or all tests
echo -e "${GREEN}Select tests to run:${NC}"
echo -e "1. All tests"
echo -e "2. Bronze layer tests"
echo -e "3. Silver layer tests"
echo -e "4. Gold layer tests"
echo -e -n "${YELLOW}Enter your choice [1]: ${NC}"
read choice

case $choice in
    1|"")
        echo "Running all tests..."
        python -m pytest tests/
        ;;
    2)
        echo "Running bronze layer tests..."
        python -m pytest tests/test_bronze_layer.py
        ;;
    3)
        echo "Running silver layer tests..."
        python -m pytest tests/test_silver_layer.py
        ;;
    4)
        echo "Running gold layer tests..."
        python -m pytest tests/test_gold_layer.py
        ;;
    *)
        echo -e "${RED}Invalid choice. Running all tests.${NC}"
        python -m pytest tests/
        ;;
esac

# Check if tests passed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed.${NC}"
    echo -e "Please fix the failing tests before deploying the framework."
    exit 1
fi

echo ""
echo -e "Next steps:"
echo -e "1. Deploy the framework to Databricks workspaces"
echo -e "2. Run the DLT pipeline"
echo -e "3. Monitor the pipeline execution"
echo ""
echo -e "For more information, refer to the README.md file."
echo ""
