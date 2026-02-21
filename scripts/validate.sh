#!/usr/bin/env bash
set -euo pipefail

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for chart in charts/*; do
  if [[ ! -d "$chart" ]]; then
    continue
  fi

  chart_name="$(basename "$chart")"
  if [[ "$chart_name" == "_templates" ]]; then
    continue
  fi

  echo "[lint] $chart"
  helm lint "$chart"

  if [[ -f "$chart/values.schema.json" ]]; then
    echo "[schema] $chart has values schema"
  else
    echo "[schema] missing values.schema.json in $chart"
    exit 1
  fi

  rendered_any=false
  for env_file in environments/*/"${chart_name}"-values.yaml; do
    if [[ ! -f "$env_file" ]]; then
      continue
    fi

    rendered_any=true
    env_name="$(basename "$(dirname "$env_file")")"
    rendered="$tmp_dir/${chart_name}-${env_name}.yaml"

    echo "[render] $chart_name ($env_name)"
    helm template "${chart_name}-${env_name}" "$chart" -f "$chart/values.yaml" -f "$env_file" > "$rendered"

    if command -v kubeconform >/dev/null 2>&1; then
      echo "[kubeconform] $chart_name ($env_name)"
      kubeconform -strict -summary "$rendered"
    fi

    if command -v conftest >/dev/null 2>&1; then
      echo "[conftest] $chart_name ($env_name)"
      conftest test "$rendered" --policy policies/conftest
    fi
  done

  if [[ "$rendered_any" == false ]]; then
    rendered="$tmp_dir/${chart_name}.yaml"
    echo "[render] $chart_name (default)"
    helm template "${chart_name}-default" "$chart" -f "$chart/values.yaml" > "$rendered"

    if command -v kubeconform >/dev/null 2>&1; then
      echo "[kubeconform] $chart_name (default)"
      kubeconform -strict -summary "$rendered"
    fi

    if command -v conftest >/dev/null 2>&1; then
      echo "[conftest] $chart_name (default)"
      conftest test "$rendered" --policy policies/conftest
    fi
  fi
done

echo "Validation completed"
