#!/bin/bash

ISSUE_NUMBER=$1
REPO_FULLNAME=$2
TEAM_SLUG=$3
TOKEN=$4

COMMENTERS_URL="https://api.github.com/repos/$REPO_FULLNAME/issues/$ISSUE_NUMBER/comments"

# Get the commenters who have written '!skip'
commenters_res=$(curl -s -H "Authorization: Bearer $TOKEN" \
                     -H "X-GitHub-Api-Version: 2022-11-28" \
                     -H "Accept: application/vnd.github.v3+json" \
                  $COMMENTERS_URL)
commenters=$(echo $commenters_res | jq -r '.[] | select(.body == "!skip") | .user.login')

ORG_NAME=$(echo $REPO_FULLNAME | cut -f1 -d"/")

echo "Org name: $ORG_NAME"

# Get the field org_users from the evaluation/settings.json file
org_users=$(jq '.org_users' evaluation/settings.json)

echo "Org users: $org_users"

# Check if any of the commenters who wrote '!skip' are in the maintainers/developers list
for commenter in $commenters; do
  if echo "$org_users" | grep -q "$commenter"; then

    echo "Found !skip comment by $commenter"

    # Skip command found, exit with a special code
    exit 78
  fi
done

echo "No !skip comment found"
# No skip command found, exit normally
exit 0
