#!/usr/bin/env bash
# Runs the exact hook of each platform on real Terraform plans and checks its exit code. It runs no
# vendor code, so it proves the commands and says nothing about what a platform does with the exit code.
# The sample repository is ../atlantis/sample. ipso, terraform, git, and yq have to be on PATH.
set -euo pipefail

cd "$(dirname "$0")"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

spacelift_hook="$(yq -r '.stacks.network.before_apply[0]' spacelift/.spacelift/config.yml)"
env0_hook="$(yq -r '.deploy.steps.terraformPlan.after[0]' env0/env0.yml)"

# repo <public value> <plan file name> prints a checkout of the sample with a real plan in terraform/.
repo() {
  local dir
  dir="$(mktemp -d "${work}/repo.XXXXXX")"
  cp -R ../atlantis/sample/. "${dir}/"
  git -C "$dir" init -q
  sed -i.bak "s/public = false/public = $1/" "${dir}/terraform/main.tf"
  rm -f "${dir}/terraform/main.tf.bak"
  (
    cd "${dir}/terraform"
    terraform init -input=false >/dev/null
    terraform plan -input=false -out "$2" >/dev/null
  )
  printf '%s' "$dir"
}

# expect <wanted exit> <name> <command...>
expect() {
  local want="$1" name="$2" got=0
  shift 2
  "$@" >/dev/null 2>&1 || got=$?
  if { [ "$want" -eq 0 ] && [ "$got" -ne 0 ]; } || { [ "$want" -ne 0 ] && [ "$got" -eq 0 ]; }; then
    fail "${name}: exit ${got}, want ${want}"
  fi
  echo "ok: ${name} exits ${got}"
}

spacelift() {
  (cd "$1/terraform" && sh -c "$spacelift_hook")
}

env0() {
  local dir="$1"
  (cd "${dir}/terraform" && terraform show -json default.tfplan >"${dir}/plan.json")
  (cd "${dir}/terraform" && ENV0_ROOT_DIR="$dir" ENV0_TF_PLAN_JSON="${dir}/plan.json" sh -c "$env0_hook")
}

env0_without_plan() {
  (cd "$1/terraform" && env -u ENV0_TF_PLAN_JSON ENV0_ROOT_DIR="$1" sh -c "$env0_hook")
}

# The script names the plan at Scalr's documented path. This points it at the sample's plan.
scalr() {
  local dir="$1" script
  script="${dir}/hook.sh"
  sed "s|/opt/data/terraform.tfplan.bin|${dir}/terraform/terraform.tfplan.bin|" scalr/ipso-pre-apply.sh >"$script"
  (cd "${dir}/terraform" && sh "$script")
}

break_decision() {
  sed -i.bak 's/^status: accepted/status: nonsense/' "$1/docs/decisions/0001-private-endpoints.md"
}

echo "== Spacelift"
expect 1 "a blocking violation" spacelift "$(repo true spacelift.plan)"
expect 0 "only a warning" spacelift "$(repo false spacelift.plan)"
dir="$(repo false spacelift.plan)"
break_decision "$dir"
expect 1 "an invalid decision" spacelift "$dir"
dir="$(repo false other.plan)"
expect 1 "a missing plan file" spacelift "$dir"

echo "== env0"
expect 1 "a blocking violation" env0 "$(repo true default.tfplan)"
expect 0 "only a warning" env0 "$(repo false default.tfplan)"
dir="$(repo false default.tfplan)"
break_decision "$dir"
expect 1 "an invalid decision" env0 "$dir"
expect 1 "no plan JSON from the platform" env0_without_plan "$(repo false default.tfplan)"

echo "== Scalr"
expect 1 "a blocking violation" scalr "$(repo true terraform.tfplan.bin)"
expect 0 "only a warning" scalr "$(repo false terraform.tfplan.bin)"
dir="$(repo false terraform.tfplan.bin)"
break_decision "$dir"
expect 1 "an invalid decision" scalr "$dir"
expect 1 "a missing plan file" scalr "$(repo false other.plan)"

echo "PASS: each hook exits non-zero on a block and zero on a warning. No vendor platform ran."
