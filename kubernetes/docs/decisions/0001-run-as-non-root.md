---
edr: 1
id: 01M6D9H4Y4T43V8X3Z91E6GNPQ
slug: run-as-non-root
title: "Pods run as non-root"
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
  - engine: kyverno
    ref: policies/run-as-non-root.yaml
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/kubernetes
tags: [kubernetes, sample]
---

# Pods run as non-root

## Context

A container that runs as root turns a container escape into a much worse day, and one value in a chart is enough to allow it.

## Decision

Every pod sets `runAsNonRoot: true`.

## Alternatives considered

- Enforce it only at admission: authors would find out at deploy time rather than in review.

## Consequences

This check blocks, so a chart or an overlay that renders a root pod fails its job. An exception needs a reviewed waiver.

## Verification

`ipso render` writes the manifests, and `ipso check kyverno` evaluates them.
