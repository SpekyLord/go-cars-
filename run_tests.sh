#!/bin/bash

# GoCars Test Runner
# Scans for all .test.gd files and runs them with Godot headless

echo "========================================"
echo "       GoCars Test Runner"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find all test files
TEST_FILES=$(find . -name "*.test.gd" -type f)

if [ -z "$TEST_FILES" ]; then
    echo -e "${YELLOW}No test files found (.test.gd)${NC}"
    echo "Create test files with .test.gd extension"
    exit 0
fi

PASSED=0
FAILED=0
TOTAL=0

# Run each test file
for test_file in $TEST_FILES; do
    TOTAL=$((TOTAL + 1))
    echo -e "${YELLOW}Running:${NC} $test_file"
    
    # Run the test and capture output
    OUTPUT=$(godot --path . --headless --script "$test_file" 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "$OUTPUT"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

# Summary
echo "========================================"
echo "            SUMMARY"
echo "========================================"
echo -e "Total:  $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
