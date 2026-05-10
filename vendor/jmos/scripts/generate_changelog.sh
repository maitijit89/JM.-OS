#!/bin/bash
# JM OS Changelog Generator

echo "Generating JM OS Changelog..."
echo "============================="
echo "Build Date: $(date)"
echo ""

# Get commits since last tag or 7 days
git log --since="7 days ago" --pretty=format:"* %s (%an)" --no-merges

echo ""
echo "============================="
echo "Changelog Generated Successfully."
