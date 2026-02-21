# Standards for Helm Charts

## Mandatory

- `values.schema.json` en cada chart.
- `resources.requests` y `resources.limits` para cada contenedor.
- `securityContext` con `runAsNonRoot: true`.
- `probes` (`liveness`, `readiness`) en workloads HTTP.
- `serviceAccount` explicito (evitar default).

## Naming

- Chart name: kebab-case
- Release name: `<team>-<service>-<env>`
- Namespaces: `<domain>-<env>`
