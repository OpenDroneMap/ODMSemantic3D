#!/bin/bash

ISSUE_NUMBER=$1
GITHUB_TOKEN=$2
REPO_FULLNAME=$3
TEAM_SLUG=$4

# Get the commenters who have written '!skip'
commenters=$(gh api repos/$REPO_FULLNAME/issues/$ISSUE_NUMBER/comments --paginate -q '.[] | select(.body == \"!skip\") | .user.login'

# Get the list of maintainers and developers
team_members=$(gh api orgs/$(echo $REPO_FULLNAME | cut -f1 -d"/")/teams/$TEAM_SLUG/members --paginate -q '.[].login')

# Check if any of the commenters who wrote '!skip' are in the maintainers/developers list
for commenter in $commenters; do
  if echo "$team_members" | grep -q "$commenter"; then
    # Skip command found, exit with a special code
    exit 78
  fi
done

# No skip command found, exit normally
exit 0