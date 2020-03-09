#!/bin/sh
kubectl get jobs --namespace="webtor" -o json | jq '.items[] | select(.status.succeeded != null or .status.failed !=null) | "kubectl delete job \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
kubectl get po --namespace="webtor" -o json | jq  '.items[] | select(.status.phase | contains("Succeeded")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
kubectl get po --namespace="webtor" -o json | jq  '.items[] | select(.status.phase | contains("Failed")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
echo "Finish cleaning!"