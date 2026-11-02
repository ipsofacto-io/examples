# examples

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/ipsofacto-io/examples/badge)](https://scorecard.dev/viewer/?uri=github.com/ipsofacto-io/examples)

Sample repositories with ipso decisions enforced on TypeScript, JVM, Terraform and Kubernetes code.

> Status: a Terraform plan check run by [`ipso-action`](https://github.com/ipsofacto-io/ipso-action), an Atlantis that refuses to apply a failing plan, Kubernetes rendering, four adapter tools, and three platform hooks. Most run real tools on every change to them, with the `ipso` v0.4.0 release. The Scalr hook has run on Scalr, and the Spacelift and env0 hooks have not run on their platforms.

Each sample is a small project that shows one canonical decision, such as private object storage, a ban on importing another service's internal package, an allow-list of Terraform modules, or Postgres as the only database.

## Terraform plan check

[`.github/workflows/ipso.yml`](.github/workflows/ipso.yml) runs `ipso check plan` on [`terraform/plan.json`](terraform/plan.json) on every pull request. It uploads a SARIF file to code scanning and keeps the evidence as an artifact.

- [`docs/decisions/0001-no-public-bucket-acl.md`](docs/decisions/0001-no-public-bucket-acl.md) blocks, and the plan obeys it, so the job stays green.
- [`docs/decisions/0002-encrypted-ebs-volumes.md`](docs/decisions/0002-encrypted-ebs-volumes.md) warns, and the plan breaks it on purpose. Its alert shows up in the Security tab of this repository.

## Atlantis

[`atlantis/`](atlantis/) runs a real Atlantis against a throwaway Gitea, with one workflow that adds `ipso check plan` to the plan stage. A plan that breaks a blocking decision fails, and `atlantis apply` then has nothing to apply. A plan that breaks only a warning applies. The `atlantis / e2e` job proves both whenever that directory changes.

## Kubernetes

[`kubernetes/`](kubernetes/) renders a Helm chart and a Kustomize overlay offline with `ipso render`, and `ipso check kyverno` reads the result. The `kubernetes / e2e` job runs the pinned tools whenever that directory changes.

## Pulumi, CloudFormation, CDK, and Bicep

[`adapters/`](adapters/) has one decision per adapter family, and one sample that passes and one that fails for each tool. The `adapters / e2e` job runs the real tools, with no cloud account, whenever that directory changes.

## Spacelift, env0, and Scalr

[`platforms/`](platforms/) holds a hook for each platform. The `platforms / hooks` job runs the exact commands on real Terraform plans and checks their exit codes. It runs no vendor code, so it says nothing about what a platform does with an exit code.

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).

Copyright 2026 Luca Bertelli.

## Contributing

Follow the contributor terms in [ipsofacto-io/.github](https://github.com/ipsofacto-io/.github/blob/main/CONTRIBUTING.md). Commits need a `Signed-off-by` trailer (`git commit -s`).
