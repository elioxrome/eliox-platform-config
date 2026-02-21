## Cargar imagen local en kind
```bash
kind load docker-image ghcr.io/sabadell/mc-user-fastapi:1.0.0-dev --name eliox-cluster
```

## Deploy con Helm (entorno dev)
```bash
helm upgrade --install mc-user-fastapi charts/mc-user-fastapi \
  --namespace mc-user-fastapi \
  --create-namespace \
  -f charts/mc-user-fastapi/values.yaml \
  -f environments/dev/mc-user-fastapi-values.yaml \
  --wait --timeout 180s
```

## Verificar recursos
```bash
kubectl -n mc-user-fastapi get deploy,pods,svc,hpa,pdb
```
