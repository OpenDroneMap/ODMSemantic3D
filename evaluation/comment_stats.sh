#!/bin/bash

# Get the list of all new-stats.json file paths created in step 7 and existing stats.json file paths
new_stats_files=$(find ground-truth -type f -name "new-stats.json")
stats_files=$(find ground-truth -type f -name "stats.json")

echo "New Stats Files: $new_stats_files"
echo "Stats Files: $stats_files"

# Create a list of pairs of stats.json and new-stats.json for each folder
paired_files=""
for new_stats_file in $new_stats_files; do
  stats_file=${new_stats_file//new-stats/stats}
  paired_files="$paired_files $stats_file $new_stats_file"
done

echo "Paired Files: $paired_files"

# Call the compare.py script in the datasets repository, passing it the list created in step 9

PR_COMMENT=$(python evaluation/compare.py $paired_files)

echo "PR Comment: $PR_COMMENT"

COMMENT_PAYLOAD=$(echo '{}' | jq --arg body "$PR_COMMENT" '.body = $body')

echo "Comment Payload: $COMMENT_PAYLOAD"

REQ_URL=$(jq -r .pull_request.comments_url "$GITHUB_EVENT_PATH")

echo "Request URL: $REQ_URL"

# Create a new comment on the PR with the output of compare.py
curl -s -S -H "Authorization: Bearer $GROUND_TRUTH_REPO_TOKEN" \
           -H "Content-Type: application/json" \
           -H "X-GitHub-Api-Version: 2022-11-28" \
           -H "Accept: application/vnd.github+json" \
           --data "$COMMENT_PAYLOAD" "$REQ_URL"