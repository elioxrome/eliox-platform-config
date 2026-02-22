# test if found permission

kubectl auth can-i create deployment -n apps --as=system:serviceaccount:cicd:jenkins-deployer
kubectl auth can-i patch deployment -n apps --as=system:serviceaccount:cicd:jenkins-deployer
kubectl auth can-i get pods -n apps --as=system:serviceaccount:cicd:jenkins-deployer

# genera token temporal

kubectl -n cicd create token jenkins-deployer --duration=24h

# genero mi kubeconfig para jenkins

## verifico si puedo crear deployment

kubectl auth can-i create deployments -n apps --as=system:serviceaccount:cicd:jenkins-deployer 

## creo un kubeconfig para mi jenkins secrets

kubectl config

kind get kubeconfig --name local-cluster > kind-bootstrap.kubeconfig 

En Jenkins → Credentials:

Tipo: Secret file

ID: por ejemplo kubeconfig-bootstrap-kind

Contenido: el kubeconfig que te da kind
