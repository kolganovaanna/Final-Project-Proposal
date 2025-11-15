#!/bin/bash
set -euo pipefail

file="$1"

echo "Last line of $file:"
tail -n 1 "$file" | head -n 1

echo "Second line of $file:"
tail -n +2 "$file" | head -n 1
