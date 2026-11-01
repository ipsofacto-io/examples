---
edr: 1
id: 01M6D2A7QXGZ4H8K3N9PV5T6WB
slug: private-endpoints
title: "Service endpoints stay private"
status: accepted
owner: team:platform
scope:
  - org: ipsofacto-io
    repo: "ipsofacto-io/examples"
valid_from: 2026-11-01
valid_to: null
review_by: 2027-11-01
supersedes: []
criticality: blocking
checks:
  - engine: opa
    target: terraform-plan
    ref: policies/private-endpoints.rego
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/atlantis
tags: [network, sample]
---

# Service endpoints stay private

## Context

A public endpoint is reachable by anyone, and one attribute in a Terraform file is enough to open it.

## Decision

No service endpoint in this repository is public.

## Alternatives considered

- Review every endpoint by hand: a plan check runs on every change and does not get tired.

## Consequences

This check blocks, so `atlantis apply` has nothing to apply while a plan breaks it. A public endpoint needs a reviewed waiver.

## Verification

`ipso check plan` evaluates `policies/private-endpoints.rego` on every plan Atlantis runs.
