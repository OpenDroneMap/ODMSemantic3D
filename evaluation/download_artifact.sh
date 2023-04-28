#!/bin/bash

# Ensure that all required arguments are provided
if [ $# -ne 4 ]; then
  echo "Usage: download_artifact.sh <repo-owner> <repo-name> <workflow-name> <artifact-name> <token>"
  exit 1
fi

# Assign the provided arguments to bash variables
REPO=$1
WORKFLOW_NAME=$2
ARTIFACT_NAME=$3
TOKEN=$4

# Ensure that all the provided arguments are non-empty
if [ -z "$REPO" ]; then
  echo "Repo owner is empty"
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

# Ensure required curl, jq, unzip, tr, fold, head commands are available
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

if ! command -v tr &> /dev/null; then
  echo "tr could not be found"
  exit 1
fi

if ! command -v fold &> /dev/null; then
  echo "fold could not be found"
  exit 1
fi

if ! command -v head &> /dev/null; then
  echo "head could not be found"
  exit 1
fi


echo "Downloading artifact \"$ARTIFACT_NAME\" from workflow \"$WORKFLOW_NAME\" of \"$REPO\""

# Get the latest workflow run ID for the specific workflow
RUN_ID=$(curl --silent --show-error --request GET \
  --url "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_NAME/runs" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq '.workflow_runs[0].id')

echo "Run ID: $RUN_ID"

# Get the artifact download URL for the specific artifact
ARTIFACT_DOWNLOAD_URL=$(curl --silent --show-error --request GET \
  --url "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/artifacts" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Authorization: Bearer $TOKEN" \
  | jq -r ".artifacts[] | select(.name == \"$ARTIFACT_NAME\") | .archive_download_url")

echo "Artifact download URL: $ARTIFACT_DOWNLOAD_URL"

# Create a random string of 8 path-safe characters
RANDOM_STRING=$(dd if=/dev/urandom bs=1 count=64 | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

TMP_ARTIFACT_NAME="$ARTIFACT_NAME-$RANDOM_STRING.zip"

# Download the artifact
curl --silent --show-error --location \
     --header "Authorization: Bearer $TOKEN" \
     --output /tmp/$TMP_ARTIFACT_NAME $ARTIFACT_DOWNLOAD_URL

# List contents of zip file
unzip -l /tmp/$TMP_ARTIFACT_NAME

# Extract the artifact in the current folder and remove the zip file
unzip -q -o /tmp/$TMP_ARTIFACT_NAME -d .
rm -rf /tmp/$TMP_ARTIFACT_NAME

echo "Extracted artifact: $ARTIFACT_NAME"