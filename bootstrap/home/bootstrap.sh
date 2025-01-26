# create k3d cluster
k3d cluster create --config k3d.config.yaml

# create sops key secret
kubectl create namespace flux-system
op read "op://Private/ed25519 key/age/secret key" | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin

# set GITHUB_TOKEN env var
flux bootstrap github --token-auth --owner=reuben --repository=home-cluster --branch=main --path=clusters/home --personal
