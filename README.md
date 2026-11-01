# examples

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/ipsofacto-io/examples/badge)](https://scorecard.dev/viewer/?uri=github.com/ipsofacto-io/examples)

Sample repositories with ipso decisions enforced on TypeScript, JVM, Terraform and Kubernetes code.

> Status: two samples so far, a Terraform plan check run by [`ipso-action`](https://github.com/ipsofacto-io/ipso-action) and an Atlantis that refuses to apply a failing plan. More samples land in a later change and will pin released ipso versions.

Each sample is a small project that shows one canonical decision, such as private object storage, a ban on importing another service's internal package, an allow-list of Terraform modules, or Postgres as the only database.

## Terraform plan check

[`.github/workflows/ipso.yml`](.github/workflows/ipso.yml) runs `ipso check plan` on [`terraform/plan.json`](terraform/plan.json) on every pull request. It uploads a SARIF file to code scanning and keeps the evidence as an artifact.

- [`docs/decisions/0001-no-public-bucket-acl.md`](docs/decisions/0001-no-public-bucket-acl.md) blocks, and the plan obeys it, so the job stays green.
- [`docs/decisions/0002-encrypted-ebs-volumes.md`](docs/decisions/0002-encrypted-ebs-volumes.md) warns, and the plan breaks it on purpose. Its alert shows up in the Security tab of this repository.

## Atlantis

[`atlantis/`](atlantis/) runs a real Atlantis against a throwaway Gitea, with one workflow that adds `ipso check plan` to the plan stage. A plan that breaks a blocking decision fails, and `atlantis apply` then has nothing to apply. A plan that breaks only a warning applies. The `atlantis / e2e` job proves both whenever that directory changes.

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).

Copyright 2026 Luca Bertelli.

## Contributing

Follow the contributor terms in [ipsofacto-io/.github](https://github.com/ipsofacto-io/.github/blob/main/CONTRIBUTING.md). Commits need a `Signed-off-by` trailer (`git commit -s`).
