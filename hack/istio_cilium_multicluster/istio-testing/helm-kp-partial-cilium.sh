helm install cilium cilium/cilium --version 1.12.0 \
    --namespace kube-system \
    --set kubeProxyReplacement=partial \
    --set nodePort.enabled=true \
    --set externalIPs.enabled=true
