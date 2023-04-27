#!/bin/bash

REPO_OWNER=$1
REPO_NAME=$2
WORKFLOW_NAME=$3
ARTIFACT_NAME=$4
TOKEN=$5

# Get the latest workflow run ID for the specific workflow
RUN_ID=$(curl --silent --request GET \
  --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_NAME/runs" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq '.workflow_runs[0].id')

# Get the artifact download URL for the specific artifact
ARTIFACT_DOWNLOAD_URL=$(curl --silent --request GET \
  --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID/artifacts" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq -r ".artifacts[] | select(.name == \"$ARTIFACT_NAME\") | .archive_download_url")

# Download the artifact
curl --location --remote-name --progress-bar \
  --url "$ARTIFACT_DOWNLOAD_URL" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN"

# Extract the artifact (assuming it's a .zip file)
unzip $ARTIFACT_NAME.zip