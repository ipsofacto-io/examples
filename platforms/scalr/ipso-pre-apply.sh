#!/bin/sh
# Attach this at pre-apply, in the workspace settings or the hooks registry.
set -eu
terraform show -json /opt/data/terraform.tfplan.bin > /tmp/plan.json
# A CLI-driven workspace is not a git checkout. There, use: cd /opt/workdir
cd "$(git rev-parse --show-toplevel)"
ipso check
ipso compile
ipso check plan /tmp/plan.json
