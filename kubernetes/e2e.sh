#!/usr/bin/env bash
# Renders the sample chart and overlay with the pinned tools and checks the verdict on each.
# ipso, helm, kustomize, and kyverno have to be on PATH at the releases ipso pins.
set -euo pipefail

cd "$(dirname "$0")"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# check <wanted exit> <text the output must hold> <directory>
check() {
  local want="$1" text="$2" dir="$3" got=0 output
  output="$(ipso check kyverno "$dir" 2>&1)" || got=$?
  printf '%s\n' "$output"
  [ "$got" -eq "$want" ] || fail "${dir}: exit ${got}, want ${want}"
  case "$output" in
    *"$text"*) ;;
    *) fail "${dir}: the output does not hold \"${text}\"" ;;
  esac
}

ipso check
ipso compile

echo "== a chart with compliant values"
ipso render helm helm/api --out rendered/helm-pass
check 0 "run-as-non-root: checks[0] (block): pass" rendered/helm-pass

echo "== a chart with values that run as root"
ipso render helm helm/api --values helm/values-root.yaml --out rendered/helm-fail
check 1 "run-as-non-root: checks[0] (block): default/Pod/ipso-api: runAsNonRoot must be true" rendered/helm-fail

echo "== a compliant overlay"
ipso render kustomize kustomize/overlays/prod --out rendered/kustomize-pass
check 0 "run-as-non-root: checks[0] (block): pass" rendered/kustomize-pass

echo "== an overlay that runs as root"
ipso render kustomize kustomize/overlays/root --out rendered/kustomize-fail
check 1 "run-as-non-root: checks[0] (block): " rendered/kustomize-fail

echo "PASS: Helm and Kustomize manifests reach the checks, and a violation is an ordinary verdict"
