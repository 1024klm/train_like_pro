#!/bin/bash

# Check for div/li with onClick (anti-semantic pattern)

echo "🔍 Checking for clickable div/li elements..."

# Look for div or li with onClick
violations=$(grep -rE '(<div|<li)[^>]*onClick' src/ --include='*.elm' || true)

if [ -n "$violations" ]; then
    echo "❌ Found clickable div/li elements. Use semantic elements instead:"
    echo "$violations"
    echo ""
    echo "Replace with:"
    echo "  - <button> for actions"
    echo "  - <a> for navigation"
    echo "  - <label> for form controls"
    exit 1
else
    echo "✅ No clickable div/li elements found"
fi