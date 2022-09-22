kubectl create -f https://k8s.io/examples/application/deployment.yaml

kubectl expose deployment nginx-deployment --type=ClusterIP

