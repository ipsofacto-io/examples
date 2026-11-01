# Pulumi, CloudFormation, CDK, and Bicep samples

One decision per adapter family, and for each tool one sample that passes and one that fails. [`ipso/docs/adapters.md`](https://github.com/ipsofacto-io/ipso/blob/main/docs/adapters.md) explains the commands and their limits.

| Tool | Samples | Written by | Checked with |
| --- | --- | --- | --- |
| Pulumi | [`pulumi/`](pulumi/) | `pulumi preview --json`, with a local backend | `ipso check pulumi` |
| CloudFormation | [`cloudformation/`](cloudformation/) | Nothing: the template is the input | `ipso check cloudformation` |
| CDK | [`cdk/`](cdk/) | `cdk synth`, with a context value that picks the sample | `ipso check cloudformation` |
| Bicep | [`bicep/`](bicep/) | `bicep build`. The storage account is inside a module | `ipso check arm` |

None of them needs a cloud account, and every failing sample fails on purpose. The Pulumi samples use the `random` provider. [`e2e.sh`](e2e.sh) runs all of them, and the `adapters / e2e` job runs the script with pinned tools whenever this directory changes.

```bash
npm ci --ignore-scripts --prefix adapters/cdk
bash adapters/e2e.sh
```
