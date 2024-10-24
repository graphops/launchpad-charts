#!/bin/env bash

set -exuo pipefail

# Define the required Go version.
GO_VERSION="1.21.1"
EXPECTED_GO_PATH="$HOME/go"

# Function to display an error message and exit with a non-zero status code.
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Download and install Go.
echo "Installing Go $GO_VERSION..."
curl -o "$HOME/go.tar" -L "https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
tar -C "$HOME" -xzf "$HOME/go.tar"
echo "Go $GO_VERSION has been successfully installed."

# Update appVersion in graph-network-indexer Chart.yaml
echo "Updating appVersion in graph-network-indexer Chart.yaml..."

# Extract image tags from values.yaml
INDEXER_SERVICE_RS_TAG=$(awk '/indexerService:/, /tag:/{if(/tag:/) print $2}' ./charts/graph-network-indexer/values.yaml | sed 's/"//g')
echo "INDEXER_SERVICE_RS_TAG: $INDEXER_SERVICE_RS_TAG"
INDEXER_TAP_AGENT_TAG=$(awk '/indexerTapAgent:/, /tag:/{if(/tag:/) print $2}' ./charts/graph-network-indexer/values.yaml | sed 's/"//g')
echo "INDEXER_TAP_AGENT_TAG: $INDEXER_TAP_AGENT_TAG"
INDEXER_AGENT_TAG=$(awk '/indexerAgent:/, /tag:/{if(/tag:/) print $2}' ./charts/graph-network-indexer/values.yaml | sed 's/"//g')
echo "INDEXER_AGENT_TAG: $INDEXER_AGENT_TAG"

# Construct the appVersion string
APP_VERSION="indexer-service-rs-${INDEXER_SERVICE_RS_TAG}-indexer-tap-agent-${INDEXER_TAP_AGENT_TAG}-indexer-agent-${INDEXER_AGENT_TAG}"

# Update the Chart.yaml with the new appVersion
sed -i "s/^appVersion: .*/appVersion: \"${APP_VERSION}\"/" "$(pwd)/charts/graph-network-indexer/Chart.yaml"

echo "appVersion has been updated successfully."

# Add Go binaries to PATH.
export PATH="$PATH:$EXPECTED_GO_PATH/bin"

# Install helm-docs.
echo "Installing helm-docs..."
go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
echo "helm-docs has been successfully installed."

# Generate documentation.
echo "Generating documentation..."
helm-docs --template-files=./templates.gotmpl --template-files=README.md.gotmpl
echo "Documentation has been generated successfully."
