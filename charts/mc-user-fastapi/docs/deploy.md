## uso de kind para cargar la imagen en el registry 
kind load docker-image mc-user-fastapi:latest --name eliox-cluster

## apply for helm 
helm upgrade --install mc-user-fastapi deploy/helm/mc-user-fastapi `
  --namespace mc-user-fastapi --create-namespace `
  --set image.repository=mc-user-fastapi `
  --set image.tag=latest `
  --wait --timeout 120s

## get info for deployment
kubectl -n mc-user-fastapi get deploy,pods,svc
