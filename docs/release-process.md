# Release Process

1. Crear PR con cambios del chart.
2. CI valida lint, schema y policies.
3. Merge a `main`.
4. Crear tag: `chart-<chart>-v<semver>`.
5. Workflow `release-charts` empaqueta charts.
6. Promocion de valores por `scripts/promote.sh` + PR de entorno.
