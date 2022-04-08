#!/bin/sh

# We want to continue in the case of command failure, so let's not set this:
# set -eo pipefail

usage() {
  echo "$(basename $0) <chart>"
  echo "<chart> The name of chart in charts/ that you want to lint"
  exit 1
}

CHART_FOLDER=$1; shift

if [ -z "$CHART_FOLDER" ]; then
  usage
fi

CHART_PATH="$(dirname $0)/../charts/$CHART_FOLDER"

TEMPLATE_OUTPUT=$(helm template $CHART_PATH 2>&1)

echo "$TEMPLATE_OUTPUT"

echo "$TEMPLATE_OUTPUT" | kubeval
echo "$TEMPLATE_OUTPUT" | kube-score score -
echo "$TEMPLATE_OUTPUT" | docker run -i kubesec/kubesec scan /dev/stdin