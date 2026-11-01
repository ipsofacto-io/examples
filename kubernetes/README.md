# Kubernetes sample

A Helm chart and a Kustomize overlay, rendered offline by `ipso render` and checked by `ipso check kyverno`. [`ipso/docs/kubernetes.md`](https://github.com/ipsofacto-io/ipso/blob/main/docs/kubernetes.md) explains the commands.

- [`docs/decisions/0001-run-as-non-root.md`](docs/decisions/0001-run-as-non-root.md) is one blocking decision.
- [`helm/api`](helm/api) renders a compliant pod with its defaults, and a root pod with [`helm/values-root.yaml`](helm/values-root.yaml).
- [`kustomize/overlays/prod`](kustomize/overlays/prod) is compliant, and [`kustomize/overlays/root`](kustomize/overlays/root) patches the base to run as root.
- [`e2e.sh`](e2e.sh) renders all four and checks each verdict.

The `kubernetes / e2e` job installs the pinned tools and runs the script whenever this directory changes.

```bash
bash kubernetes/e2e.sh
```
