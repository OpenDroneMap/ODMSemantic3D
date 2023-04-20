#!/bin/bash

# Step 1: Download the latest release of the OPC repository
#wget https://github.com/uav4geo/OpenPointClass/releases/download/latest/opc.tar.gz
wget https://digipa.it/wp-content/uploads/opc.tar.gz
tar -xzvf opc.tar.gz
chmod +x pctrain pcclassify

# Step 2: Get the list of all point cloud file paths in the datasets repository
DATASET_FILES=$(find . -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply")

echo "Dataset Files: $DATASET_FILES"

# Step 3: Load training settings from settings.json
SCALES=$(jq '.scales' evaluation/settings.json)
RESOLUTION=$(jq '.resolution' evaluation/settings.json)
RADIUS=$(jq '.radius' evaluation/settings.json)

echo "SCALES: $SCALES"
echo "RESOLUTION: $RESOLUTION"
echo "RADIUS: $RADIUS"

# Step 4: Execute pctrain on all point clouds from step 2 with the settings from step 3
./pctrain --classifier gbt --scales $SCALES --resolution $RESOLUTION --radius $RADIUS --output new-model.bin $DATASET_FILES

# Step 5: Checkout the ground truth repository is done in the workflow.yml

# Step 6: Get the list of all point cloud file paths in the ground truth repository
GROUND_TRUTH_FILES=$(find ground-truth -type f -iname "*.laz" -o -iname "*.las" -o -iname "*.ply")

echo "Ground Truth Files: $GROUND_TRUTH_FILES"

# Step 7: Execute pcclassify for each point cloud from step 6 with the new-model.bin from step 4 and stats-file new-stats.json
for FILE in $GROUND_TRUTH_FILES; do
  OUTPUT_FILE="${FILE%.*}_classified.${FILE##*.}"
  ./pcclassify --regularization local_smooth --reg-radius $RADIUS --eval --stats-file new-stats.json $FILE $OUTPUT_FILE new-model.bin
done

# Step 8: Get the list of all new-stats.json file paths created in step 7 and existing stats.json file paths
new_stats_files=$(find ground-truth -type f -name "new-stats.json")
stats_files=$(find ground-truth -type f -name "stats.json")

echo "New Stats Files: $new_stats_files"
echo "Stats Files: $stats_files"

# Step 9: Create a list of pairs of stats.json and new-stats.json for each folder
paired_files=""
for new_stats_file in $new_stats_files; do
  stats_file=${new_stats_file//new-stats/stats}
  paired_files="$paired_files $stats_file $new_stats_file"
done

echo "Paired Files: $paired_files"

# Step 10: Call the compare.py script in the datasets repository, passing it the list created in step 9
# Step 11: Create a new comment on the PR with the output of compare.py from step 10
PR_COMMENT=$(python evaluation/compare.py $paired_files)

echo "PR Comment: $PR_COMMENT"

PR_NUMBER=$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')

echo "PR Number: $PR_NUMBER"

COMMENT_PAYLOAD=$(echo '{}' | jq --arg body "$PR_COMMENT" '.body = $body')

echo "Comment Payload: $COMMENT_PAYLOAD"

curl -s -S -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" --data "$COMMENT_PAYLOAD" "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments"

# Step 12: Add new-model.bin to the PR
git config --global user.email "github-action@example.com"
git config --global user.name "GitHub Action"
git add new-model.bin
git commit -m "Add new-model.bin"
git push origin HEAD:$GITHUB_HEAD_REF