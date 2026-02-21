SHELL := /bin/bash
CHART ?= bs-fastapi-repo
ENV ?= dev

.PHONY: validate package template

validate:
	./scripts/validate.sh

package:
	./scripts/package.sh

template:
	helm template $(CHART) charts/$(CHART) -f environments/$(ENV)/$(CHART)-values.yaml
