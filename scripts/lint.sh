#!/bin/sh

# We want to continue in the case of command failure, so let's not set this:
set -euo pipefail

usage() {
  echo "$(basename -- "$0") <chart>"
  echo "<chart> The name of chart in charts/ that you want to lint"
  echo "Requires: container engine, kubeval, kube-score and helm available"
  exit 1
}

crun() {
if type podman > /dev/null; then
  podman "$@"
elif type docker > /dev/null; then
  docker "$@"
else
  : "$@"
fi
}

CHART_FOLDER=${1:-}; shift || :

if [ -z "$CHART_FOLDER" ] || ! type helm > /dev/null; then
  usage
fi

CHART_PATH="$(dirname "$0")/../charts/$CHART_FOLDER"

TEMPLATE_OUTPUT="$(helm template "$CHART_PATH")"

echo "$TEMPLATE_OUTPUT"

echo "$TEMPLATE_OUTPUT" | kubeval || :
echo "$TEMPLATE_OUTPUT" | kube-score score - || :
echo "$TEMPLATE_OUTPUT" | crun run -i kubesec/kubesec scan /dev/stdin || :
