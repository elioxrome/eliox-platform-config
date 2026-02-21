# Blueprint DevOps para Repositorio de Helm Charts

Estructura avanzada para gestionar Helm Charts y manifiestos Kubernetes:

- Estandarizacion de charts para multiples servicios.
- Promocion por entornos (`dev` -> `stg` -> `prd`).
- Validaciones de calidad, seguridad y compliance en CI.
- Publicacion versionada de charts.
- Operacion y runbooks.

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
│   ├── bs-fastapi-repo/
│   └── mc-user-fastapi/
├── environments/
│   ├── dev/
│   ├── stg/
│   └── prd/
├── ci/
│   ├── chart-testing-config.yaml
│   └── lintconf.yaml
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

1. El equipo de plataforma mantiene el estandar en `charts/_templates/base`.
2. Cada servicio vive en `charts/<servicio>`.
3. Overrides por entorno en `environments/<env>`.
4. En cada Pull Request se ejecutan lint, schema, render y policy checks.
5. Merge a `main` + tag semver publica chart versionado.

## Comandos

```bash
make validate
make package
make template CHART=bs-fastapi-repo ENV=dev
```

## Herramientas necesarias en este repositorio

| Herramienta | Requerida | Para que se usa |
|---|---|---|
| `helm` | Si | Lint, render y dry-run de charts (`helm lint`, `helm template`, `helm install --dry-run`). |
| `ct` (chart-testing) | Si en CI / recomendable en local | Valida charts con reglas de release (por ejemplo, `version` bump) y calidad en PRs. |
| `yamllint` | Si con `ct` | `ct` lo usa para validar estilo y calidad YAML de `Chart.yaml` y `values`. |
| `conftest` | Recomendada (obligatoria si aplicas policies) | Ejecuta politicas Rego sobre manifiestos renderizados para compliance y seguridad. |
| `kubeconform` | Recomendada | Valida que los manifiestos Kubernetes renderizados cumplan schema del API. |
| `make` | Recomendada | Estandariza ejecucion local con `make test-local`, `make validate`, etc. |
| `python3` + `pip` | Recomendada | Permite instalar utilidades como `yamllint` facilmente. |
| `kubectl` | Opcional | Verificacion manual de recursos cuando revisas en cluster. |
| `kind` | Opcional | Entorno local de pruebas Kubernetes sin usar cluster compartido. |

### Comprobacion rapida

```bash
helm version
ct version
yamllint --version
conftest --version
kubeconform -v
```

Si alguna no esta instalada, `make test-local` degrada validaciones opcionales y lo indica en la salida.

## Convenciones clave

- Versionado SemVer en `Chart.yaml` (`version`).
- Imagen de la app en `appVersion`.
- Todo chart debe incluir `values.schema.json`.
- `CODEOWNERS` obliga aprobacion del equipo DevOps.

# Conftest

Conftest te ayuda a escribir pruebas sobre configuraciones estructuradas.
Con Conftest puedes validar configuraciones de Kubernetes, pipelines Tekton, Terraform, Serverless y otros formatos.

Conftest usa Rego (Open Policy Agent) para definir reglas.
Documentacion oficial:

- OPA: https://www.openpolicyagent.org/
- Conftest: https://www.conftest.dev/

Ejemplo de politica (`policy/deployment.rego`):

```rego
package main

deny contains msg if {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot
  msg := "Los contenedores no deben ejecutarse como root"
}

deny contains msg if {
  input.kind == "Deployment"
  not input.spec.selector.matchLabels.app
  msg := "Los contenedores deben definir la etiqueta app para el selector"
}
```

Ejemplo de ejecucion:

```bash
conftest test deployment.yaml
```

# Probar sin desplegar

## Validar chart + schema

```bash
helm lint charts/mc-user-fastapi -f environments/dev/mc-user-fastapi-values.yaml
```

## Renderizar manifiestos (sin instalar)

```bash
helm template mc-user-fastapi charts/mc-user-fastapi \
  -f charts/mc-user-fastapi/values.yaml \
  -f environments/dev/mc-user-fastapi-values.yaml > /tmp/mc-user-fastapi-dev.yaml
```

## Validar manifiestos Kubernetes

```bash
kubeconform -strict -summary /tmp/mc-user-fastapi-dev.yaml
```

## Validar politicas OPA/Conftest

```bash
conftest test /tmp/mc-user-fastapi-dev.yaml --policy policies/conftest
```

## Simular instalacion completa (dry-run)

```bash
helm install --dry-run --debug mc-user-fastapi charts/mc-user-fastapi \
  -f environments/dev/mc-user-fastapi-values.yaml
```

## Lint estilo CI con `ct` (sin exigir bump mientras iteras)

```bash
ct lint --all --config ci/chart-testing-config.yaml
```
