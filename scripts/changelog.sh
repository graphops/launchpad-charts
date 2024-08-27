#!/bin/env bash

set -euo pipefail

usage() {
  echo "$(basename -- "$0") <chart>"
  echo "<chart> The name of chart in charts/ for which you want to generate a changelog"
  exit 1
}

readonly BASE_DIR="$(dirname "$0")"
readonly ROOT="$(realpath "$BASE_DIR/../")"
readonly CHARTS_RELDIR="charts"

CHART="${1:-}"

if [ -z "${CHART}" ]; then
  usage
fi

pushd "$ROOT" > /dev/null

CHART_PATH="$CHARTS_RELDIR/$CHART"

GIT_CLIFF__GIT__TAG_PATTERN="$CHART-*" \
  GIT_CLIFF__GIT__IGNORE_TAGS="$CHART-v?[0-9]+.[0-9]+.[0-9]+-.*" \
  yarn git-cliff -c "$ROOT/.cliff.toml" --include-path "$CHART_PATH/**"

popd > /dev/null
