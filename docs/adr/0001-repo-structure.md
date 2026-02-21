# ADR-0001: Helm Repo Structure

## Status
Accepted

## Context
Se requiere una estructura unificada para charts multi-servicio, con controles DevOps centralizados.

## Decision
Usar un repo con:

- `charts/` para charts de servicios
- `environments/` para overrides por entorno
- `policies/` para compliance como codigo
- `.github/workflows/` para pipelines

## Consequences

- Mayor gobernanza y consistencia
- Cambios de estructura deben pasar por equipo DevOps
