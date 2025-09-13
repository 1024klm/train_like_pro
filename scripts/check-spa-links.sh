#!/bin/bash

# Check for raw onClick (NavigateTo) usage instead of onPreventDefaultClick

echo "🔍 Checking for raw onClick (NavigateTo) usage..."

# Look for onClick (NavigateTo pattern in src/
violations=$(grep -rE 'onClick[[:space:]]*\([[:space:]]*NavigateTo' src/ --include='*.elm' || true)

if [ -n "$violations" ]; then
    echo "❌ Found raw SPA navigation clicks. Use onPreventDefaultClick for SPA links:"
    echo "$violations"
    echo ""
    echo "Replace onClick (NavigateTo route) with onPreventDefaultClick (NavigateTo route)"
    echo "for proper SPA navigation with preventDefault behavior."
    exit 1
else
    echo "✅ No raw SPA navigation clicks found"
fi