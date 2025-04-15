alias kcgpunodes='kubectl get nodes -o=jsonpath="{range .items[*]}{.metadata.name}{\" GPUs: \"}{.status.allocatable.nvidia\\.com/gpu}{\"\n\"}{end}"'

#### alias kcgpupods='kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name,REQUESTED_GPU:.spec.containers[*].resources.requests.nvidia\.com/gpu,USED_GPU:.status.containerStatuses[*].resources.limits.nvidia\.com/gpu" | awk "\$3!=\"<none>\" && \$3!=\"0\""'

alias kcgpupods='kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name,REQUESTED_GPU:.spec.containers[*].resources.requests.nvidia\.com/gpu" | awk "\$3!=\"<none>\" && \$3!=\"0\""'
