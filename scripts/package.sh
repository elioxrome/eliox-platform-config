#!/usr/bin/env bash
set -euo pipefail

mkdir -p .dist

for chart in charts/*; do
  if [[ ! -d "$chart" ]] || [[ "$(basename "$chart")" == "_templates" ]]; then
    continue
  fi

  echo "Packaging $chart"
  helm dependency update "$chart"
  helm package "$chart" --destination .dist
done

echo "Packages available in .dist/"
