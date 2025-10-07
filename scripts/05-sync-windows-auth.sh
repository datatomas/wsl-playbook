#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure folder
mkdir -p ~/.azure

# 2) Copy tokens from Windows profile (adjust username path if needed)
cp "/mnt/c/Users/SuarezTo/.azure/"* ~/.azure/ 2>/dev/null || true

# 3) Verify
ls -l ~/.azure

# Alt: symlink instead of copy (keeps both in sync). Comment copy above if you use this.
# rm -rf ~/.azure
# ln -s "/mnt/c/Users/SuarezTo/.azure" ~/.azure
