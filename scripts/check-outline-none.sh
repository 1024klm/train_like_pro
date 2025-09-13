#!/bin/bash

# Check for outline: none without :focus-visible

echo "🔍 Checking for outline: none usage..."

# Look for outline: none in CSS files
violations=$(grep -rE 'outline:\s*none' src/ public/ --include='*.css' --include='*.elm' | grep -v 'focus:outline-none' | grep -v 'focus-visible' || true)

if [ -n "$violations" ]; then
    echo "❌ Found outline: none without focus-visible. This breaks keyboard accessibility:"
    echo "$violations"
    echo ""
    echo "Use instead:"
    echo "  - focus:outline-none focus:ring-2 focus:ring-blue-500 (Tailwind)"
    echo "  - outline: none with :focus-visible alternative"
    exit 1
else
    echo "✅ No problematic outline: none found"
fi