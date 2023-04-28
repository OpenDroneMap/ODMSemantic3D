#!/bin/bash

# Ensure that all required arguments are provided
if [ $# -ne 5 ]; then
  echo "Usage: download_artifact.sh <repo-owner> <repo-name> <workflow-name> <artifact-name> <token>"
  exit 1
fi

# Assign the provided arguments to bash variables
REPO_OWNER=$1
REPO_NAME=$2
WORKFLOW_NAME=$3
ARTIFACT_NAME=$4
TOKEN=$5

# Ensure that all the provided arguments are non-empty
if [ -z "$REPO_OWNER" ]; then
  echo "Repo owner is empty"
  exit 1
fi

if [ -z "$REPO_NAME" ]; then
  echo "Repo name is empty"
  exit 1
fi

if [ -z "$WORKFLOW_NAME" ]; then
  echo "Workflow name is empty"
  exit 1
fi

if [ -z "$ARTIFACT_NAME" ]; then
  echo "Artifact name is empty"
  exit 1
fi

if [ -z "$TOKEN" ]; then
  echo "Token is empty"
  exit 1
fi

# Ensure required curl, jq and unzip commands are available
if ! command -v curl &> /dev/null; then
  echo "curl could not be found"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "jq could not be found"
  exit 1
fi

if ! command -v unzip &> /dev/null; then
  echo "unzip could not be found"
  exit 1
fi

echo "Downloading artifact \"$ARTIFACT_NAME\" from workflow \"$WORKFLOW_NAME\" of \"$REPO_OWNER/$REPO_NAME\""

# Get the latest workflow run ID for the specific workflow
RUN_ID=$(curl --silent --request GET \
  --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_NAME/runs" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq '.workflow_runs[0].id')

echo "Run ID: $RUN_ID"

# Get the artifact download URL for the specific artifact
ARTIFACT_DOWNLOAD_URL=$(curl --silent --request GET \
  --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID/artifacts" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq -r ".artifacts[] | select(.name == \"$ARTIFACT_NAME\") | .archive_download_url")

echo "Artifact download URL: $ARTIFACT_DOWNLOAD_URL"

# Download the artifact
curl --silent --show-error --location \
     --header "Authorization: Bearer $TOKEN" \
     --output $ARTIFACT_NAME.zip $ARTIFACT_DOWNLOAD_URL

# Extract the artifact (assuming it's a .zip file)
unzip -o $ARTIFACT_NAME.zip
rm $ARTIFACT_NAME.zip

echo "Extracted artifact: $ARTIFACT_NAME"