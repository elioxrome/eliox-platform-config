## firts apply with manifest

kubectl apply -f deploy/k8s/namespace.yaml; kubectl apply -f deploy/k8s/deployment.yaml; kubectl apply -f deploy/k8s/service.yaml; kubectl -n mc-user-fastapi rollout status deployment/mc-user-fastapi --timeout=120s
