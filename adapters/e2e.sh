#!/usr/bin/env bash
# Runs each real tool on a sample that passes and a sample that fails, and checks each verdict.
# ipso, pulumi, bicep, node, and the npm packages of cdk/ have to be installed.
set -euo pipefail

cd "$(dirname "$0")"

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# verdict <wanted exit> <text the output must hold> <ipso check args...>
verdict() {
  local want="$1" text="$2" got=0 output
  shift 2
  output="$(ipso check "$@" 2>&1)" || got=$?
  printf '%s\n' "$output"
  [ "$got" -eq "$want" ] || fail "ipso check $*: exit ${got}, want ${want}"
  case "$output" in
    *"$text"*) ;;
    *) fail "ipso check $*: the output does not hold \"${text}\"" ;;
  esac
}

ipso check
ipso compile

echo "== Pulumi"
export PULUMI_BACKEND_URL="file://${out}"
export PULUMI_CONFIG_PASSPHRASE=throwaway
for sample in pass fail; do
  (
    cd "pulumi/${sample}"
    pulumi stack select --create dev --non-interactive >/dev/null
    pulumi preview --json --non-interactive >"${out}/${sample}.json"
  )
done
verdict 0 "long-generated-passwords: checks[0] (block): pass" pulumi "${out}/pass.json"
verdict 1 "RandomPassword::databasePassword: generated passwords have at least 16 characters" pulumi "${out}/fail.json"

echo "== CloudFormation"
verdict 0 "no-public-buckets: checks[0] (block): pass" cloudformation cloudformation/pass.yaml
# The failing template is written here, so the repository holds no public bucket for its own scans to flag.
sed 's/AccessControl: Private/AccessControl: PublicRead/' cloudformation/pass.yaml >"${out}/fail.yaml"
verdict 1 "LogsBucket: S3 buckets have no public ACL" cloudformation "${out}/fail.yaml"

echo "== CDK"
(
  cd cdk
  npx --no-install cdk synth --quiet --output "${out}/cdk-pass" >/dev/null
  npx --no-install cdk synth --quiet --context public=true --output "${out}/cdk-fail" >/dev/null
)
verdict 0 "no-public-buckets: checks[0] (block): pass" cloudformation "${out}/cdk-pass/AdaptersSample.template.json"
verdict 1 "S3 buckets have no public ACL" cloudformation "${out}/cdk-fail/AdaptersSample.template.json"

echo "== Bicep"
for sample in pass fail; do
  bicep build "bicep/${sample}.bicep" --outfile "${out}/${sample}-arm.json"
done
verdict 0 "no-public-blobs: checks[0] (block): pass" arm "${out}/pass-arm.json"
verdict 1 "Microsoft.Storage/storageAccounts/ipsosamplepublic: storage accounts refuse public blob access" arm "${out}/fail-arm.json"

echo "PASS: each tool's real output reached its check, and a violation is an ordinary verdict"
