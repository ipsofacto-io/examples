---
edr: 1
id: 01M6DBK6A6Z98A3284E6KBNTVW
slug: no-public-buckets
title: "S3 buckets have no public ACL"
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
    target: cloudformation-template
    ref: policies/no-public-buckets.rego
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/adapters
tags: [sample]
---

# S3 buckets have no public ACL

## Context

A public ACL exposes every object in a bucket. This decision covers CloudFormation templates and what `cdk synth` writes.

## Decision

S3 buckets have no public ACL.

## Alternatives considered

- Review it by hand: a check runs on every change and does not get tired.

## Consequences

This check blocks, so a change that breaks it fails its job.

## Verification

`ipso check cloudformation` evaluates `policies/no-public-buckets.rego`.
