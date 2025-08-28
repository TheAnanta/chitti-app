#!/bin/bash

# Comprehensive Test Runner for Chitti App
# This script runs all test categories and generates a summary report

echo "🧪 Starting Comprehensive Test Suite for Chitti App"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
UNIT_TESTS_RESULT=0
WIDGET_TESTS_RESULT=0
INTEGRATION_TESTS_RESULT=0
PERFORMANCE_TESTS_RESULT=0

echo ""
echo -e "${BLUE}📋 Running Unit Tests (Data Models & Repositories)${NC}"
echo "---------------------------------------------------"
flutter test test/data/ --reporter=compact
UNIT_TESTS_RESULT=$?

echo ""
echo -e "${BLUE}🎨 Running Widget Tests (UI Components)${NC}"
echo "--------------------------------------"
flutter test test/widgets/ --reporter=compact
WIDGET_TESTS_RESULT=$?

echo ""
echo -e "${BLUE}🔗 Running Domain Tests (Network & API)${NC}"
echo "--------------------------------------"
flutter test test/domain/ --reporter=compact
DOMAIN_TESTS_RESULT=$?

echo ""
echo -e "${BLUE}🏃 Running Performance Tests${NC}"
echo "----------------------------"
flutter test test/performance/ --reporter=compact
PERFORMANCE_TESTS_RESULT=$?

echo ""
echo -e "${BLUE}🌐 Running Integration Tests${NC}"
echo "----------------------------"
flutter test test/integration/ --reporter=compact
INTEGRATION_TESTS_RESULT=$?

echo ""
echo -e "${BLUE}💨 Running Basic Widget Smoke Tests${NC}"
echo "----------------------------------"
flutter test test/widget_test.dart --reporter=compact
SMOKE_TESTS_RESULT=$?

# Generate summary report
echo ""
echo "📊 TEST SUMMARY REPORT"
echo "======================"

if [ $UNIT_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Unit Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Unit Tests: ${RED}FAILED${NC}"
fi

if [ $WIDGET_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Widget Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Widget Tests: ${RED}FAILED${NC}"
fi

if [ $DOMAIN_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Domain Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Domain Tests: ${RED}FAILED${NC}"
fi

if [ $PERFORMANCE_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Performance Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Performance Tests: ${RED}FAILED${NC}"
fi

if [ $INTEGRATION_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Integration Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Integration Tests: ${RED}FAILED${NC}"
fi

if [ $SMOKE_TESTS_RESULT -eq 0 ]; then
    echo -e "✅ Smoke Tests: ${GREEN}PASSED${NC}"
else
    echo -e "❌ Smoke Tests: ${RED}FAILED${NC}"
fi

echo ""
echo "🔍 IDENTIFIED ISSUES (from test analysis):"
echo "=========================================="
echo -e "${RED}🚨 CRITICAL ISSUES:${NC}"
echo "  - DRY Violation: submitReview method duplicated in multiple files"
echo "  - Null Safety: Force unwrapping FirebaseAuth.instance.currentUser!"
echo "  - Commented Validation: Review validation logic is disabled"
echo ""
echo -e "${YELLOW}⚠️  PERFORMANCE ISSUES:${NC}"
echo "  - Potential memory leaks in video player controllers"
echo "  - No caching limits in repository layer"
echo "  - Complex nested widget structures causing potential jank"
echo ""
echo -e "${YELLOW}⚠️  EDGE CASE VULNERABILITIES:${NC}"
echo "  - No validation for instructor rating bounds"
echo "  - Missing error handling for malformed API responses"
echo "  - No offline mode support"

# Calculate overall result
TOTAL_FAILURES=$((UNIT_TESTS_RESULT + WIDGET_TESTS_RESULT + DOMAIN_TESTS_RESULT + PERFORMANCE_TESTS_RESULT + INTEGRATION_TESTS_RESULT + SMOKE_TESTS_RESULT))

echo ""
if [ $TOTAL_FAILURES -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo "The comprehensive test suite has identified potential issues for improvement."
else
    echo -e "${RED}💥 SOME TESTS FAILED!${NC}"
    echo "Please review the test failures above and the identified issues."
fi

echo ""
echo "📖 For detailed analysis, see: test/TEST_DOCUMENTATION.md"
echo "🔧 To run specific test categories:"
echo "   flutter test test/data/         # Unit tests"
echo "   flutter test test/widgets/      # Widget tests"
echo "   flutter test test/domain/       # Network tests"
echo "   flutter test test/performance/  # Performance tests"
echo "   flutter test test/integration/  # Integration tests"

exit $TOTAL_FAILURES