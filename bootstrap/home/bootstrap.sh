# before deleting cluster for recreation, backup volumes and claims
kubectl get pv -A -o json | jq '.items[] | select(.spec.storageClassName == "local-path")' | jq -M 'del(.spec.claimRef)' > volumes.json
kubectl get pvc -A -o json | jq '.items[] | select(.spec.storageClassName == "local-path")' > claims.json

# create k3d cluster
#SOPS_AGE_KEY=$(op read "op://Private/ed25519 key/age/secret key") sops exec-file k3d.config.yaml 'k3d cluster create --config {}'
k3d cluster create --config k3d.config.yaml

# create sops key secret
kubectl create namespace flux-system
op read "op://Private/ed25519 key/age/secret key" | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin

# apply backed up volumes and PVCs if needed
kubectl apply -f volumes.json
kubectl create namespace home-assistant
kubectl create namespace datomic
kubectl apply -f claims.json

# set GITHUB_TOKEN env var
GITHUB_TOKEN=$(op read "op://Private/reuben GitHub/Personal Access Tokens/Scripting token") flux bootstrap github --token-auth --owner=reuben --repository=home-cluster --branch=main --path=clusters/home --personal
