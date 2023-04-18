# If the PR is merged:
# Create a new file "pr_merged.sh" in the root directory of the repository "datasets"
# Add the following content to the "pr_merged.sh" file:

#!/bin/bash

# Step 1: Replace model.bin with new-model.bin in the "datasets" repository
mv new-model.bin model.bin
git add model.bin
git commit -m "Replace model.bin with new-model.bin"
git push origin main

# Steps 2-4 are handled in the GitHub Actions workflow configuration

# Step 5: Replace stats.json files with new-stats.json files in the "ground-truth" repository
find ground-truth -type f -iname "new-stats.json" -exec bash -c 'mv $0 ${0/new-/}' {} \;
git add ground-truth
git commit -m "Replace stats.json with new-stats.json"
git push origin main