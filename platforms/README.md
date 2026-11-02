# Spacelift, env0, and Scalr hooks

The hook for each platform, as [`ipso/docs/platforms.md`](https://github.com/ipsofacto-io/ipso/blob/main/docs/platforms.md) describes it.

- [`spacelift/.spacelift/config.yml`](spacelift/.spacelift/config.yml) sets a `before_apply` hook.
- [`env0/env0.yml`](env0/env0.yml) sets a custom flow after the plan.
- [`scalr/ipso-pre-apply.sh`](scalr/ipso-pre-apply.sh) is a script to attach at pre-apply.

> The Scalr script ran on Scalr on 2026-11-02, and a blocking violation stopped the apply, as [Validation on Scalr](https://github.com/ipsofacto-io/ipso/blob/main/docs/platforms.md#validation-on-scalr) records. That workspace was CLI-driven and not a git checkout, so its hook used `cd /opt/workdir` in place of the `git rev-parse` line. The Spacelift and env0 hooks have not run on their platforms. [`test-hooks.sh`](test-hooks.sh) reads each hook from its file and runs it on real Terraform plans of the [Atlantis sample](../atlantis/sample), so it proves the commands and their exit codes. It runs no vendor code, so it says nothing about what a platform does with that exit code. The `platforms / hooks` job runs the script whenever this directory changes.

```bash
bash platforms/test-hooks.sh
```
