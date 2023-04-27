#!/bin/bash

# Download the latest release of the OPC repository
latest_release_url=$(curl -s "https://api.github.com/repos/uav4geo/OpenPointClass/releases/latest" | jq -r '.assets[0].browser_download_url')
wget $latest_release_url -O opc.tar.gz
tar -xzvf opc.tar.gz
chmod +x pctrain pcclassify

# Get the list of all point cloud file paths in the datasets repository excluding the ground-truth folder
DATASET_FILES=$(find . -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply" | grep -v "ground-truth")

echo "Dataset Files: $DATASET_FILES"

# Load training settings from settings.json
SCALES=$(jq '.scales' evaluation/settings.json)
RESOLUTION=$(jq '.resolution' evaluation/settings.json)
RADIUS=$(jq '.radius' evaluation/settings.json)

echo "SCALES: $SCALES"
echo "RESOLUTION: $RESOLUTION"
echo "RADIUS: $RADIUS"

# Step 4: Execute pctrain on all point clouds from step 2 with the settings from step 3
./pctrain --classifier gbt --scales $SCALES --resolution $RESOLUTION --radius $RADIUS --output new-model.bin $DATASET_FILES

# Get the list of all point cloud file paths in the ground truth repository
GROUND_TRUTH_FILES=$(find ground-truth -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply")

echo "Ground Truth Files: $GROUND_TRUTH_FILES"

# Execute pcclassify for each point cloud from step 6 with the new-model.bin from step 4 and stats-file new-stats.json
for FILE in $GROUND_TRUTH_FILES; do

  OUTPUT_FILE="${FILE%.*}_classified.${FILE##*.}"

  # Calculate the new-stats.json file path
  FOLDER=$(dirname $FILE)
  NEW_STATS_FILE="${FOLDER}/new-stats.json"

  ./pcclassify --regularization local_smooth --reg-radius $RADIUS --eval --stats-file $NEW_STATS_FILE $FILE $OUTPUT_FILE new-model.bin
done