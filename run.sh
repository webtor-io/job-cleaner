#!/bin/sh
kubectl get pods -n webtor | grep Terminating | awk '{print $1}' | grep seeder | xargs kubectl delete po --force --grace-period=0 -n webtor
kubectl get pods -n webtor | grep Terminating | awk '{print $1}' | grep transcoder | xargs kubectl delete po --force --grace-period=0 -n webtor
kubectl get jobs --namespace="webtor" -o json | jq '.items[] | select(.status.succeeded != null or .status.failed !=null) | "kubectl delete job \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
kubectl get po --namespace="webtor" -o json | jq  '.items[] | select(.status.phase | contains("Pending")) | select(.status.conditions[0].lastTransitionTime | fromdateiso8601? < ((now | floor) - 5)) | select(.metadata.ownerReferences != null)  | .metadata.ownerReferences[0] | select(.name | match("(transcoder|seeder)")) | "kubectl delete job \(.name) -n webtor"' | xargs -n 1 sh -c
kubectl get po --namespace="webtor" -o json | jq  '.items[] | select(.status.phase | contains("Succeeded")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
kubectl get po --namespace="webtor" -o json | jq  '.items[] | select(.status.phase | contains("Failed")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 sh -c
echo "Finish cleaning!"