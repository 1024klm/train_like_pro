#!/bin/bash

# Check for arbitrary z-index classes in source files
# Only allow predefined z-index utilities from styles.css

echo "🔍 Checking for arbitrary z-index classes..."

# Look for z-[...] pattern in src/ excluding styles.css
violations=$(grep -r "z-\[" src/ --exclude="styles.css" || true)

if [ -n "$violations" ]; then
    echo "❌ Found arbitrary z-index classes. Use predefined z-* utilities instead:"
    echo "$violations"
    echo ""
    echo "Available z-index utilities:"
    echo "  z-base (1), z-dropdown (10), z-sticky (20), z-fixed (30)"
    echo "  z-overlay (40), z-modal (50), z-notification (60), z-tooltip (70), z-critical (80)"
    exit 1
else
    echo "✅ No arbitrary z-index classes found"
fi