# Atlantis sample

A [real Atlantis](https://www.runatlantis.io/) that refuses to apply a Terraform plan when `ipso check plan` fails on a blocking decision. [`ipso/docs/atlantis.md`](https://github.com/ipsofacto-io/ipso/blob/main/docs/atlantis.md) explains the workflow.

- [`repos.yaml`](repos.yaml) is the server-side Atlantis config with the `ipso` workflow.
- [`Dockerfile`](Dockerfile) is the Atlantis image with a checksum-pinned ipso release.
- [`sample/`](sample/) is the repository under test: a Terraform project, two decisions, and their policies. It uses `terraform_data`, so it needs no provider and no cloud account.
- [`compose.yaml`](compose.yaml) and [`e2e.sh`](e2e.sh) start a throwaway Gitea and Atlantis, and drive the sample through both.

## Run it

You need Docker with Compose, `curl`, `git`, `jq`, and `openssl`. Nothing leaves your machine, and both services listen on loopback only.

```bash
bash atlantis/e2e.sh
```

The script opens a pull request in Gitea and reads the comments Atlantis posts:

1. The plan sets `public = true`. `private-endpoints` blocks, Atlantis reports a plan error with the resource and the reason, and the plan file is gone.
2. A comment says `atlantis apply`. Nothing is applied and the state stays empty.
3. A new commit sets `public = false`. The plan passes `private-endpoints`, and `endpoint-owner` prints a warning.
4. A comment says `atlantis apply`. The apply succeeds with that warning still open.

The `atlantis / e2e` job runs the same script on every pull request in this repository.
