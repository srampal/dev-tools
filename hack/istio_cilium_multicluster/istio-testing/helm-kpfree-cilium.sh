helm install cilium cilium/cilium --version 1.12.0 \
    --namespace kube-system \
    --set kubeProxyReplacement=partial \
    --set socketLB.enabled=true \
    --set nodePort.enabled=true \
    --set externalIPs.enabled=true \
    --set hostPort.enabled=true \
    --set k8sServiceHost=${API_SERVER_IP} \
    --set k8sServicePort=${API_SERVER_PORT}

