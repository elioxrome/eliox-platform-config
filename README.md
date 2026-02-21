# Helm Charts DevOps Repository Blueprint

Estructura avanzada para gestionar Helm Charts y manifiestos k8s:

- Estandarizacion de charts para multiples servicios
- Promocion por entornos (`dev` -> `stg` -> `prd`)
- Validaciones de calidad, seguridad y compliance en CI
- Publicacion versionada de charts
- Operacion y runbooks

## Estructura

```text
.
├── .github/
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   └── workflows/
│       ├── helm-ci.yml
│       ├── security.yml
│       └── release.yml
├── charts/
│   ├── _templates/base/
│   └── bs-fastapi-repo/
├── environments/
│   ├── dev/
│   ├── stg/
│   └── prd/
├── ci/
│   └── chart-testing-config.yaml
├── policies/
│   └── conftest/main.rego
├── scripts/
│   ├── validate.sh
│   ├── package.sh
│   └── promote.sh
├── docs/
│   ├── standards.md
│   ├── release-process.md
│   ├── runbooks/
│   └── adr/
├── Makefile
└── .pre-commit-config.yaml
```

## Flujo recomendado

1. Equipo de plataforma mantiene el estandar en `charts/_templates/base`.
2. Cada servicio vive en `charts/<servicio>`.
3. Overrides por entorno en `environments/<env>`.
4. Pull Request ejecuta lint, schema, rendering y policy checks.
5. Merge a `main` + tag semver publica chart versionado.

## Comandos

```bash
make validate
make package
make template CHART=bs-fastapi-repo ENV=dev
```

## Tooling recomendado

- Obligatorio: `helm`
- Opcional: `kubeconform`, `conftest` (el script los usa automaticamente si estan instalados)

## Convenciones clave

- Versionado SemVer en `Chart.yaml` (`version`).
- Imagen de app en `appVersion`.
- Todo chart debe incluir `values.schema.json`.
- `CODEOWNERS` obliga aprobacion del equipo DevOps.
