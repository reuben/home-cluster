# create k3d cluster
k3d cluster create --config k3d.config.yaml

# set GITHUB_TOKEN env var
flux bootstrap github --token-auth --owner=reuben --repository=home-cluster --branch=main --path=clusters/home --personal
