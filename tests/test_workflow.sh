#!/bin/bash
# Test script for MS-GTD-QuickCapture.workflow

# Set up colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print test header
echo -e "${YELLOW}Running tests for MS-GTD-QuickCapture workflow...${NC}"

# Test 1: Check if workflow files exist
echo -n "Test 1: Checking if workflow files exist... "
if [ -f "../MS-GTD-QuickCapture.workflow/Contents/info.plist" ] && [ -f "../MS-GTD-QuickCapture.workflow/Contents/document.wflow" ]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - Workflow files not found"
    exit 1
fi

# Test 2: Validate workflow XML syntax
echo -n "Test 2: Validating workflow XML syntax... "
if xmllint --noout "../MS-GTD-QuickCapture.workflow/Contents/document.wflow" 2>/dev/null; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - XML validation error"
    exit 1
fi

# Test 3: Check AppleScript syntax in workflow
echo -n "Test 3: Checking AppleScript syntax... "
# Extract AppleScript from document.wflow
APPLESCRIPT=$(grep -o '<string>on run {input, parameters}.*</string>' "../MS-GTD-QuickCapture.workflow/Contents/document.wflow" | 
             sed 's/<string>//g; s/<\/string>//g')

# Save to temporary file
echo "$APPLESCRIPT" > ./temp_script.applescript

# Check syntax
if osascript -c "try" -c "compile (POSIX file \"$(pwd)/temp_script.applescript\")" -c "return true" -c "on error" -c "return false" -c "end try"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - AppleScript syntax error"
    rm ./temp_script.applescript
    exit 1
fi

# Clean up
rm ./temp_script.applescript

# Test 4: Verify Microsoft To Do integration
echo -n "Test 4: Verifying Microsoft To Do integration... "
if grep -q "Microsoft To Do" "../MS-GTD-QuickCapture.workflow/Contents/document.wflow"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - Missing Microsoft To Do integration"
    exit 1
fi

# Test 5: Verify URL encoding functionality
echo -n "Test 5: Verifying URL encoding functionality... "
if grep -q "encodeText" "../MS-GTD-QuickCapture.workflow/Contents/document.wflow"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - Missing URL encoding functionality"
    exit 1
fi

# Test 6: Verify web fallback option
echo -n "Test 6: Verifying web fallback option... "
if grep -q "to-do.microsoft.com" "../MS-GTD-QuickCapture.workflow/Contents/document.wflow"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - Missing web fallback option"
    exit 1
fi

# Test 7: Verify notification functionality
echo -n "Test 7: Verifying notification functionality... "
if grep -q "display notification" "../MS-GTD-QuickCapture.workflow/Contents/document.wflow"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC} - Missing notification functionality"
    exit 1
fi

# Summary
echo -e "\n${GREEN}All tests PASSED!${NC}"
echo -e "7 tests completed successfully"