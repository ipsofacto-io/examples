#!/usr/bin/env bash
# Drives the sample through a real Atlantis and a real Gitea, and fails unless:
#   1. a plan that breaks the blocking decision fails, and `atlantis apply` applies nothing;
#   2. a plan that breaks only the warning decision prints the warning and applies.
# Every secret is generated here and dies with the containers.
set -euo pipefail

cd "$(dirname "$0")"

GITEA_URL=http://127.0.0.1:3000
OWNER=developer
REPO=sample
TIMEOUT_SECONDS=240
DATA_DIR=/home/atlantis/.atlantis

workdir="$(mktemp -d)"
developer_password="$(openssl rand -hex 16)"
atlantis_password="$(openssl rand -hex 16)"
ATLANTIS_GITEA_WEBHOOK_SECRET="$(openssl rand -hex 32)"
export ATLANTIS_GITEA_WEBHOOK_SECRET
export ATLANTIS_GITEA_TOKEN=""

compose() {
  docker compose --profile atlantis "$@"
}

cleanup() {
  status=$?
  if [ "$status" -ne 0 ]; then
    # The metrics lines of a debug log would push everything else out of the job log.
    compose logs --no-color gitea atlantis 2>&1 | grep -v 'metrics/debug.go' | tail -n 200 || true
  fi
  compose down --volumes --remove-orphans || true
  rm -rf "$workdir"
  exit "$status"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

gitea_cli() {
  docker compose exec -T -u git gitea gitea "$@"
}

api() {
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    curl -fsS -X "$method" -H "Authorization: token ${developer_token}" -H "Content-Type: application/json" -d "$body" "${GITEA_URL}/api/v1${path}"
  else
    curl -fsS -X "$method" -H "Authorization: token ${developer_token}" "${GITEA_URL}/api/v1${path}"
  fi
}

# wait_for_comment <pull> <after-count> <text>: prints the first comment after that count holding the text.
wait_for_comment() {
  local pull="$1" after="$2" text="$3" deadline found
  deadline=$((SECONDS + TIMEOUT_SECONDS))
  while [ "$SECONDS" -lt "$deadline" ]; do
    found="$(api GET "/repos/${OWNER}/${REPO}/issues/${pull}/comments" | jq -r --argjson after "$after" --arg text "$text" \
      '[.[$after:][] | select(.user.login == "atlantis") | select(.body | contains($text)) | .body] | first // empty')"
    if [ -n "$found" ]; then
      printf '%s\n' "$found"
      return 0
    fi
    sleep 3
  done
  fail "no Atlantis comment with \"${text}\" on pull ${pull} within ${TIMEOUT_SECONDS}s"
}

comment_count() {
  api GET "/repos/${OWNER}/${REPO}/issues/$1/comments" | jq 'length'
}

post_comment() {
  api POST "/repos/${OWNER}/${REPO}/issues/$1/comments" "$(jq -cn --arg body "$2" '{body: $body}')" >/dev/null
}

state_resources() {
  # Prints how many state files Atlantis keeps for this pull hold a resource.
  compose exec -T atlantis sh -c "find ${DATA_DIR}/repos -name terraform.tfstate -exec grep -l terraform_data {} + 2>/dev/null | wc -l | tr -d ' '"
}

plan_files() {
  compose exec -T atlantis sh -c "find ${DATA_DIR}/repos -name '*.tfplan' 2>/dev/null | wc -l | tr -d ' '"
}

echo "== start Gitea"
docker compose up --detach --wait --wait-timeout "$TIMEOUT_SECONDS" gitea
deadline=$((SECONDS + TIMEOUT_SECONDS))
until curl -fsS "${GITEA_URL}/api/healthz" >/dev/null 2>&1; do
  [ "$SECONDS" -lt "$deadline" ] || fail "Gitea did not become healthy"
  sleep 2
done

echo "== create the users and tokens"
gitea_cli admin user create --username "$OWNER" --password "$developer_password" --email developer@example.test --must-change-password=false >/dev/null
gitea_cli admin user create --username atlantis --password "$atlantis_password" --email atlantis@example.test --must-change-password=false >/dev/null
developer_token="$(gitea_cli admin user generate-access-token --username "$OWNER" --token-name e2e --scopes all --raw | tr -d '\r\n')"
ATLANTIS_GITEA_TOKEN="$(gitea_cli admin user generate-access-token --username atlantis --token-name atlantis --scopes all --raw | tr -d '\r\n')"
export ATLANTIS_GITEA_TOKEN

echo "== push the sample"
api POST /user/repos "$(jq -cn --arg name "$REPO" '{name: $name, default_branch: "main"}')" >/dev/null
api PUT "/repos/${OWNER}/${REPO}/collaborators/atlantis" '{"permission":"write"}' >/dev/null
api POST "/repos/${OWNER}/${REPO}/hooks" "$(jq -cn --arg secret "$ATLANTIS_GITEA_WEBHOOK_SECRET" '{
  type: "gitea",
  active: true,
  branch_filter: "*",
  events: ["push", "issue_comment", "pull_request", "pull_request_comment", "pull_request_sync"],
  config: {url: "http://atlantis:4141/events", content_type: "json", secret: $secret}
}')" >/dev/null

cp -R sample/. "${workdir}/"
git -C "$workdir" init -q -b main
git -C "$workdir" config user.name developer
git -C "$workdir" config user.email developer@example.test
git -C "$workdir" config commit.gpgsign false
git -C "$workdir" config credential.helper ""
remote="http://${OWNER}:${developer_token}@127.0.0.1:3000/${OWNER}/${REPO}.git"
git -C "$workdir" add -A
git -C "$workdir" commit -q -m "chore: add the sample"
git -C "$workdir" remote add origin "$remote"
git -C "$workdir" push -q origin main

echo "== start Atlantis"
compose up --detach --build atlantis
deadline=$((SECONDS + TIMEOUT_SECONDS))
until curl -fsS http://127.0.0.1:4141/healthz >/dev/null 2>&1; do
  [ "$SECONDS" -lt "$deadline" ] || fail "Atlantis did not become healthy"
  sleep 2
done

echo "== a pull request that breaks the blocking decision"
git -C "$workdir" checkout -q -b public-endpoint
sed -i.bak 's/public = false/public = true/' "${workdir}/terraform/main.tf"
rm -f "${workdir}/terraform/main.tf.bak"
git -C "$workdir" commit -q -am "feat: open the endpoint"
git -C "$workdir" push -q origin public-endpoint
pull="$(api POST "/repos/${OWNER}/${REPO}/pulls" '{"title":"Open the endpoint","head":"public-endpoint","base":"main"}' | jq -r '.number')"

blocked="$(wait_for_comment "$pull" 0 "private-endpoints: checks[0] (block)")"
printf '%s\n' "$blocked"
case "$blocked" in
  *"Plan Error"*) ;;
  *) fail "the blocking verdict did not fail the plan" ;;
esac
case "$blocked" in
  *"terraform_data.endpoint: service endpoints stay private"*) ;;
  *) fail "the comment does not name the resource and the reason" ;;
esac
[ "$(plan_files)" = "0" ] || fail "a plan file survived the blocking verdict"

echo "== atlantis apply must apply nothing"
before="$(comment_count "$pull")"
post_comment "$pull" "atlantis apply"
refused="$(wait_for_comment "$pull" "$before" "Apply")"
printf '%s\n' "$refused"
case "$refused" in
  *"Apply complete"*) fail "atlantis apply applied a plan that failed the verdict" ;;
esac
[ "$(state_resources)" = "0" ] || fail "a resource reached the state after the blocking verdict"

echo "== fix the plan and keep the warning"
before="$(comment_count "$pull")"
# The fix keeps a change against main, because Atlantis plans only a project the pull request changes.
sed -i.bak 's/public = true/public = false\
    tier   = "internal"/' "${workdir}/terraform/main.tf"
rm -f "${workdir}/terraform/main.tf.bak"
git -C "$workdir" commit -q -am "fix: keep the endpoint private"
git -C "$workdir" push -q origin public-endpoint

passed="$(wait_for_comment "$pull" "$before" "Plan: 1 to add")"
printf '%s\n' "$passed"
case "$passed" in
  *"private-endpoints: checks[0] (block): pass"*) ;;
  *) fail "the blocking check did not pass" ;;
esac
case "$passed" in
  *"endpoint-owner: checks[0] (warn): terraform_data.endpoint: service endpoints name an owning team"*) ;;
  *) fail "the warning did not print" ;;
esac

echo "== atlantis apply must apply the plan"
before="$(comment_count "$pull")"
post_comment "$pull" "atlantis apply"
applied="$(wait_for_comment "$pull" "$before" "Apply complete")"
printf '%s\n' "$applied"
[ "$(state_resources)" = "1" ] || fail "the resource did not reach the state"

echo "PASS: ipso blocked apply on a blocking verdict and allowed it on a warning"
