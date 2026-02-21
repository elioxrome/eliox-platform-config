#!/usr/bin/env bash
set -euo pipefail

CHART="${1:-}"
FROM_ENV="${2:-dev}"
TO_ENV="${3:-stg}"

if [[ -z "$CHART" ]]; then
  echo "Usage: $0 <chart-name> [from-env] [to-env]"
  exit 1
fi

SRC="environments/${FROM_ENV}/${CHART}-values.yaml"
DST="environments/${TO_ENV}/${CHART}-values.yaml"

if [[ ! -f "$SRC" ]]; then
  echo "Source values file not found: $SRC"
  exit 1
fi

cp "$SRC" "$DST"
echo "Promoted $CHART values from $FROM_ENV to $TO_ENV"
