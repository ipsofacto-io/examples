# Spacelift, env0, and Scalr hooks

Pre-apply hooks that run `ipso check plan` on Terraform management platforms, matching [`ipso/docs/platforms.md`](https://github.com/ipsofacto-io/ipso/blob/main/docs/platforms.md).

## Files

| Platform | Hook file | Hook stage | Live platform validation |
| --- | --- | --- | --- |
| Spacelift | [`spacelift/.spacelift/config.yml`](spacelift/.spacelift/config.yml) | `before_apply` | Not yet run on Spacelift |
| env0 | [`env0/env0.yml`](env0/env0.yml) | Custom post-plan flow | Not yet run on env0 |
| Scalr | [`scalr/ipso-pre-apply.sh`](scalr/ipso-pre-apply.sh) | Pre-apply script | Verified on Scalr (2026-11-02); blocking violation stopped apply ([notes](https://github.com/ipsofacto-io/ipso/blob/main/docs/platforms.md#validation-on-scalr)) |

Note on Scalr CLI-driven workspaces: because a CLI-driven workspace is not a git checkout, replace the `git rev-parse` line in the hook with `cd /opt/workdir`.

## Test locally

[`test-hooks.sh`](test-hooks.sh) extracts each hook command and runs it against real Terraform plans from the [Atlantis sample](../atlantis/sample) to verify command syntax and exit codes. Because it does not invoke vendor platform code, it does not test how each platform reacts to a non-zero exit. The `platforms / hooks` CI job runs this script whenever `platforms/` changes.

```bash
bash platforms/test-hooks.sh
```
