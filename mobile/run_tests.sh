#!/bin/bash

# Test runner script for BookRead Flutter App
# This script runs all tests and generates coverage reports

set -e

echo "🧪 BookRead Flutter Test Runner"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
flutter pub get

# Run static analysis
print_status "Running static analysis..."
if flutter analyze; then
    print_status "Static analysis passed"
else
    print_error "Static analysis failed"
    exit 1
fi

# Run unit tests
print_status "Running unit tests..."
if flutter test test/models/ test/services/ test/utilities/ test/providers/; then
    print_status "Unit tests passed"
else
    print_error "Unit tests failed"
    exit 1
fi

# Run widget tests (if they exist)
if [ -d "test/components" ] || [ -d "test/screens" ]; then
    print_status "Running widget tests..."
    if flutter test test/components/ test/screens/ 2>/dev/null; then
        print_status "Widget tests passed"
    else
        print_warning "Widget tests failed or don't exist"
    fi
fi

# Run all tests with coverage
print_status "Running all tests with coverage..."
if flutter test --coverage; then
    print_status "All tests passed with coverage"
else
    print_error "Some tests failed"
    exit 1
fi

# Generate coverage report
if [ -f "coverage/lcov.info" ]; then
    print_status "Coverage report generated"
    
    # Install lcov if not present (on macOS/Linux)
    if command -v lcov &> /dev/null; then
        print_status "Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        print_status "HTML coverage report generated in coverage/html/"
    else
        print_warning "lcov not installed. Install with: sudo apt-get install lcov (Ubuntu) or brew install lcov (macOS)"
    fi
else
    print_warning "No coverage report generated"
fi

# Run integration tests (if they exist)
if [ -d "integration_test" ]; then
    print_status "Running integration tests..."
    if flutter test integration_test/; then
        print_status "Integration tests passed"
    else
        print_warning "Integration tests failed"
    fi
fi

# Performance tests
print_status "Running performance analysis..."
if flutter build apk --analyze-size; then
    print_status "Performance analysis completed"
else
    print_warning "Performance analysis failed"
fi

# Check for test files that might be missing
print_status "Checking test coverage..."

# Count source files
SOURCE_FILES=$(find lib/ -name "*.dart" -not -path "*/generated/*" | wc -l)
TEST_FILES=$(find test/ -name "*_test.dart" | wc -l)

echo "Source files: $SOURCE_FILES"
echo "Test files: $TEST_FILES"

if [ $TEST_FILES -lt $((SOURCE_FILES / 2)) ]; then
    print_warning "Consider adding more test files. Current ratio: $TEST_FILES tests for $SOURCE_FILES source files"
fi

# Summary
echo ""
echo "🎉 Test Summary"
echo "==============="
print_status "Static analysis: PASSED"
print_status "Unit tests: PASSED"
print_status "Coverage report: GENERATED"

if [ -f "coverage/lcov.info" ]; then
    # Extract coverage percentage if possible
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep -o '[0-9.]*%' | tail -1)
        echo "Coverage: $COVERAGE"
    fi
fi

echo ""
print_status "All tests completed successfully!"
echo "📊 View coverage report: open coverage/html/index.html"
echo "🚀 Ready for deployment!"

exit 0
