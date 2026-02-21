# Rollback Runbook

## Detect

- Fallos en probes
- Error rate superior al umbral SLO

## Execute

```bash
helm history <release> -n <namespace>
helm rollback <release> <revision> -n <namespace>
```

## Verify

- Pods en `Running`
- Error rate recuperado
- Latencia dentro de umbral
