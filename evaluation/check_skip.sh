#!/bin/bash

ISSUE_NUMBER=$1
REPO_FULLNAME=$2
TEAM_SLUG=$3
TOKEN=$4

# Get the commenters who have written '!skip'
commenters=$(curl -s -H "Authorization: Bearer $TOKEN" \
                     -H "X-GitHub-Api-Version: 2022-11-28" \
                     -H "Accept: application/vnd.github.v3+json" \
                https://api.github.com/repos/$REPO_FULLNAME/issues/$ISSUE_NUMBER/comments \
            | jq -r '.[] | select(.body == "!skip") | .user.login')

echo "Commenters: $commenters"

ORG_NAME=$(echo $REPO_FULLNAME | cut -f1 -d"/")

echo "Org name: $ORG_NAME"

# Get the list of maintainers and developers
team_members=$(curl -s -H "Authorization: Bearer $TOKEN" \
                       -H "X-GitHub-Api-Version: 2022-11-28" \
                       -H "Accept: application/vnd.github.v3+json" \
                    https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_SLUG/members \
              | jq -r '.[].login')

# Check if any of the commenters who wrote '!skip' are in the maintainers/developers list
for commenter in $commenters; do
  if echo "$team_members" | grep -q "$commenter"; then

    echo "Found !skip comment by $commenter"

    # Skip command found, exit with a special code
    exit 78
  fi
done

# No skip command found, exit normally
exit 0
