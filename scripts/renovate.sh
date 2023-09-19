#!/bin/env bash

set -euo pipefail

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


# Add Go binaries to PATH.
export PATH="$PATH:$EXPECTED_GO_PATH/bin"

# Install helm-docs.
echo "Installing helm-docs..."
go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
echo "helm-docs has been successfully installed."

# Validate the existence of template files.
TEMPLATE_FILES="./templates.gotmpl README.md.gotmpl"

for file in $TEMPLATE_FILES; do
  if [ ! -f "$file" ]; then
    error_exit "Template file '$file' not found."
  fi
done

# Generate documentation.
echo "Generating documentation..."
helm-docs --template-files=./templates.gotmpl --template-files=README.md.gotmpl
echo "Documentation has been generated successfully."
