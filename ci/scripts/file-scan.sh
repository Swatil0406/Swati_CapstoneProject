#!/bin/bash
set -e

echo "🔍 Running basic file security scan..."

# 1. Check for sensitive files accidentally committed
echo "Checking for sensitive files..."
for file in $(find . -type f \( -name "*.pem" -o -name "*.key" -o -name "*.crt" -o -name ".env" \)); do
    echo "⚠️ Potential sensitive file found: $file"
done

# 2. Search for secrets or passwords in code
echo "Scanning for hardcoded credentials..."
grep -r -nE "(password|passwd|secret|api[_-]?key|token)" . \
    --exclude-dir={.git,node_modules,__pycache__} || true

# 3. Scan large files (could be accidentally committed)
echo "Checking for large files (>5MB)..."
find . -type f -size +5M -exec ls -lh {} \;

echo "✅ File scan completed successfully!"