Imperative Commands
#kubectl run --image=nginx
#kubectl delete pod <pod name>
#alias k="kubectl"

kubectl run nginx --image=nginx --port=80

kubectl run busybox --image=busybox --rm -it --restart=Never -- wget <nginx ip address>

Service:
Services expose a single, stable DNS name for a set of Pods with the capability of load balancing the requests across the Pods.

Kubernetes networking model is called Container Network Interface (CNI)



