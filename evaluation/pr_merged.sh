#!/bin/bash

# Zip the model.bin file and create a new release
zip model.zip model.bin
gh release create latest model.zip -t "Latest Model"

# Replace stats.json files with new-stats.json files in the "ground-truth" repository
find ground-truth -type f -iname "new-stats.json" -exec bash -c 'mv $0 ${0/new-/}' {} \;
git add ground-truth
git commit -m "Replace stats.json with new-stats.json"
git push origin main