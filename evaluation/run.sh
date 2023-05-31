#!/bin/bash

BASE_SHA=$1
HEAD_SHA=$2

# Download the latest release of the OPC repository
latest_release_url=$(curl -s "https://api.github.com/repos/uav4geo/OpenPointClass/releases/latest" | jq -r '.assets[0].browser_download_url')
wget $latest_release_url -O opc.tar.gz
tar -xzvf opc.tar.gz
chmod +x pctrain pcclassify

# settings.json has this format:
# {
#   "scales": 4,
#   "resolution": 0.1,
#   "radius": 0.5,
#   "training_set": [
#     "datasets/1.laz",
#     "datasets/2.laz",
#     "datasets/3.laz"
#   ],
#   "training_classes": [2, 3, 6, 64]
# }


# Load training settings from settings.json
SCALES=$(jq '.scales' evaluation/settings.json)
RESOLUTION=$(jq '.resolution' evaluation/settings.json)
RADIUS=$(jq '.radius' evaluation/settings.json)
TRAINING_CLASSES=$(jq '.training_classes' evaluation/settings.json)

echo "SCALES: $SCALES"
echo "RESOLUTION: $RESOLUTION"
echo "RADIUS: $RADIUS"
echo "TRAINING_CLASSES: $TRAINING_CLASSES"

# Get the list of all added or edited point cloud file paths in the datasets repository excluding the ground-truth folder
DATASET_FILES=$(git diff --name-only --diff-filter=AMR $BASE_SHA..$HEAD_SHA -- '*.laz' '*.las' '*.ply' | grep -v "ground-truth")

echo "New or edited files: $DATASET_FILES"

# Get the training_set array from settings.json and merge with the list of all added or edited point cloud file paths
TRAINING_SET=$(jq '.training_set' evaluation/settings.json)

echo "Training set: $TRAINING_SET"

# Convert the list of training set files to a space separated string
TRAINING_SET=$(echo $TRAINING_SET | tr -d '[]' | tr -d ' ' | tr ',' ' '| tr -d '"')

# Merge the two lists
DATASET_FILES="$DATASET_FILES $TRAINING_SET"
echo "New training set: $DATASET_FILES"

# List all the point cloud files in the datasets repository
ALL_DATASETS=$(find datasets -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply")
echo "All datasets: $ALL_DATASETS"

# Convert the list of training classes to a comma separated string
TRAINING_CLASSES=$(echo $TRAINING_CLASSES | tr -d '[]' | tr -d ' ')

PCTRAIN_COMMAND="./pctrain --classifier gbt --scales $SCALES --resolution $RESOLUTION --radius $RADIUS --output model.bin --classes $TRAINING_CLASSES $DATASET_FILES"

echo "Running: $PCTRAIN_COMMAND"

# Execute pctrain on all point clouds with the provided settings
./pctrain --classifier gbt --scales $SCALES --resolution $RESOLUTION --radius $RADIUS --output model.bin --classes $TRAINING_CLASSES $DATASET_FILES

# Get the list of all point cloud file paths in the ground truth repository
GROUND_TRUTH_FILES=$(find ground-truth -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply")

echo "Ground Truth Files: $GROUND_TRUTH_FILES"

NEW_STATS_FILES=""

# Execute pcclassify for each point cloud in the ground truth repository
for FILE in $GROUND_TRUTH_FILES; do

  OUTPUT_FILE="${FILE%.*}_classified.${FILE##*.}"

  # Calculate the new-stats.json file path
  FOLDER=$(dirname $FILE)
  NEW_STATS_FILE="${FOLDER}/new-stats.json"

  echo "Classifying $FILE to $OUTPUT_FILE with $NEW_STATS"

  NEW_STATS_FILES="$NEW_STATS_FILES $NEW_STATS_FILE"

  ./pcclassify --regularization local_smooth --reg-radius $RADIUS --eval --stats-file $NEW_STATS_FILE $FILE $OUTPUT_FILE model.bin
done

# Zip all new-stats.json files respecting paths
zip -r new-stats.zip $NEW_STATS_FILES
