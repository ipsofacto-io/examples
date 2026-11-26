# examples

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/ipsofacto-io/examples/badge)](https://scorecard.dev/viewer/?uri=github.com/ipsofacto-io/examples)

Working sample projects showing [ipso](https://github.com/ipsofacto-io/ipso) engineering decisions enforced across Terraform, Atlantis, Kubernetes, multi-cloud IaC tools, and CI platforms.

Each example demonstrates a real decision (such as banning public storage buckets, enforcing encrypted volumes, or blocking root containers) wired up to deterministic checks.

## Samples at a glance

| Sample | What it demonstrates | Verification status | Location |
| --- | --- | --- | --- |
| GitHub Actions + Terraform | `ipso check plan` via [`ipso-action`](https://github.com/ipsofacto-io/ipso-action) with SARIF and evidence upload | Runs in CI on every pull request (`ipso` v0.4.0) | [`.github/workflows/ipso.yml`](.github/workflows/ipso.yml) |
| Atlantis | Server-side Atlantis workflow that blocks `atlantis apply` on failing plans | End-to-end `atlantis / e2e` job against throwaway Gitea | [`atlantis/`](atlantis/) |
| Kubernetes | Offline Helm and Kustomize rendering with `ipso render` + `ipso check kyverno` | End-to-end `kubernetes / e2e` job with pinned tools | [`kubernetes/`](kubernetes/) |
| Pulumi, CloudFormation, CDK, Bicep | Passing and failing samples for each IaC adapter family | End-to-end `adapters / e2e` job with real tools (no cloud account) | [`adapters/`](adapters/) |
| Spacelift, env0, Scalr | Pre-apply platform hooks running `ipso check plan` | Hook commands tested in CI (`platforms / hooks`); Scalr verified live, Spacelift and env0 not yet run on vendor platforms | [`platforms/`](platforms/) |
| Azure Pipelines | Copy-pasteable pipeline using `IpsoCheck@1` | Exit code and artifacts verified by `ci / azure-pipelines` in [`ipso`](https://github.com/ipsofacto-io/ipso); not yet run on Azure DevOps | [`azure/azure-pipelines.yml`](azure/azure-pipelines.yml) |
| GitLab CI | Copy-pasteable pipeline using the ipso CI/CD Catalog component | Exit code and artifacts verified by `ci / gitlab` in [`ipso`](https://github.com/ipsofacto-io/ipso); not yet run on GitLab | [`.gitlab-ci.yml`](.gitlab-ci.yml) |

## Terraform plan check (GitHub Actions)

[`.github/workflows/ipso.yml`](.github/workflows/ipso.yml) runs `ipso check plan` against [`terraform/plan.json`](terraform/plan.json) on every pull request, uploads a SARIF file to GitHub Code Scanning, and retains the verdict report as a workflow artifact.

- [`docs/decisions/0001-no-public-bucket-acl.md`](docs/decisions/0001-no-public-bucket-acl.md) is a **blocking** decision that the plan satisfies, keeping the job green.
- [`docs/decisions/0002-encrypted-ebs-volumes.md`](docs/decisions/0002-encrypted-ebs-volumes.md) is a **warning** decision that the plan intentionally breaks so you can see the alert in this repository's Security tab.

## Atlantis

[`atlantis/`](atlantis/) runs a real Atlantis server against a local Gitea instance using a custom workflow that adds `ipso check plan` to the plan stage.

- A plan that breaks a **blocking** decision fails the plan step and deletes the plan file so `atlantis apply` has nothing to apply.
- A plan with only a **warning** applies normally.

The `atlantis / e2e` CI job proves both paths whenever `atlantis/` changes.

## Kubernetes (Helm and Kustomize)

[`kubernetes/`](kubernetes/) renders a Helm chart and a Kustomize overlay offline with `ipso render`, then evaluates the rendered manifests with `ipso check kyverno`. The `kubernetes / e2e` CI job runs the pinned tools whenever `kubernetes/` changes.

## Pulumi, CloudFormation, CDK, and Bicep

[`adapters/`](adapters/) contains one decision per IaC adapter family, paired with a passing sample and a failing sample for each tool. The `adapters / e2e` CI job runs the real CLI tools offline (no cloud account required) whenever `adapters/` changes.

## Spacelift, env0, and Scalr

[`platforms/`](platforms/) provides a pre-apply hook for each Terraform platform.

- The `platforms / hooks` CI job runs the exact hook commands against real Terraform plans and asserts their exit codes.
- The Scalr hook has been verified live on Scalr; Spacelift and env0 have not yet been tested on their hosted platforms.

## Azure Pipelines

[`azure/azure-pipelines.yml`](azure/azure-pipelines.yml) is a starter pipeline to copy once the ipso Azure DevOps extension is installed.

- `IpsoCheck@1` evaluates [`azure/plans/public.json`](azure/plans/public.json), which intentionally violates [`docs/decisions/0001-no-public-bucket-acl.md`](docs/decisions/0001-no-public-bucket-acl.md) and fails the job.
- `PublishPipelineArtifact@1` still uploads the SARIF file and verdict report for inspection.
- Extension publishing is manual; this pipeline has not been run on Azure DevOps yet, though its exit code and output files are verified by `ci / azure-pipelines` in [`ipsofacto-io/ipso`](https://github.com/ipsofacto-io/ipso).

## GitLab CI

[`.gitlab-ci.yml`](.gitlab-ci.yml) is a starter pipeline to copy once the ipso component is published to the GitLab CI/CD Catalog.

- The included component runs `ipso check plan` on [`gitlab/plans/public.json`](gitlab/plans/public.json), which intentionally violates [`docs/decisions/0001-no-public-bucket-acl.md`](docs/decisions/0001-no-public-bucket-acl.md) and fails the job.
- Even on failure, the job publishes the SARIF file, the verdict report, and a GitLab Code Quality report.
- Catalog publishing is manual; this pipeline has not been run on GitLab yet, though its exit code and output files are verified by `ci / gitlab` in [`ipsofacto-io/ipso`](https://github.com/ipsofacto-io/ipso).

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).

Copyright 2026 Luca Bertelli.

## Contributing

Follow the contributor guidelines in [ipsofacto-io/.github](https://github.com/ipsofacto-io/.github/blob/main/CONTRIBUTING.md). All commits require a `Signed-off-by` trailer (`git commit -s`).
