---
edr: 1
id: 01M6D2A7QXMS2J6R8C4YD7F9NE
slug: endpoint-owner
title: "Service endpoints name an owner"
status: accepted
owner: team:platform
scope:
  - org: ipsofacto-io
    repo: "ipsofacto-io/examples"
valid_from: 2026-11-01
valid_to: null
review_by: 2027-11-01
supersedes: []
criticality: warning
checks:
  - engine: opa
    target: terraform-plan
    ref: policies/endpoint-owner.rego
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/atlantis
tags: [ownership, sample]
---

# Service endpoints name an owner

## Context

An endpoint with no owner has nobody to ask when it breaks.

## Decision

Every service endpoint names an owning team.

## Alternatives considered

- Block on a missing owner: the sample shows a warning beside a blocking check, and this one is the cheaper of the two to fix later.

## Consequences

This check warns, so a plan that breaks it prints the violation and can still be applied.

## Verification

`ipso check plan` evaluates `policies/endpoint-owner.rego` on every plan Atlantis runs.
