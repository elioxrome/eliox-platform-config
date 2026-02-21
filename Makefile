SHELL := /bin/bash
CHART ?= bs-fastapi-repo
ENV ?= dev
NAMESPACE ?= $(CHART)
VALUES_FILE ?= environments/$(ENV)/$(CHART)-values.yaml
RENDER_OUT ?= /tmp/$(CHART)-$(ENV).yaml

.PHONY: validate package template test-local ct-local

validate:
	./scripts/validate.sh

package:
	./scripts/package.sh

template:
	helm template $(CHART) charts/$(CHART) -f $(VALUES_FILE)

test-local:
	@set -euo pipefail; \
	if ! command -v helm >/dev/null 2>&1; then \
	  echo "helm is required"; \
	  exit 1; \
	fi; \
	echo "[1/5] helm lint"; \
	helm lint charts/$(CHART) -f $(VALUES_FILE); \
	echo "[2/5] helm template -> $(RENDER_OUT)"; \
	helm template $(CHART) charts/$(CHART) -f charts/$(CHART)/values.yaml -f $(VALUES_FILE) > $(RENDER_OUT); \
	echo "[3/5] kubeconform (optional)"; \
	if command -v kubeconform >/dev/null 2>&1; then \
	  kubeconform -strict -summary $(RENDER_OUT); \
	else \
	  echo "kubeconform not found, skipping"; \
	fi; \
	echo "[4/5] conftest (optional)"; \
	if command -v conftest >/dev/null 2>&1; then \
	  conftest test $(RENDER_OUT) --policy policies/conftest; \
	else \
	  echo "conftest not found, skipping"; \
	fi; \
	echo "[5/5] helm install dry-run"; \
	helm install --dry-run --debug $(CHART) charts/$(CHART) -n $(NAMESPACE) -f $(VALUES_FILE) >/dev/null; \
	echo "OK: local validation completed"

ct-local:
	@set -euo pipefail; \
	if ! command -v ct >/dev/null 2>&1; then \
	  echo "ct is required"; \
	  exit 1; \
	fi; \
	ct lint --all --config ci/chart-testing-config.yaml
