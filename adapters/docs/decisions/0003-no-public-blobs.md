---
edr: 1
id: 01M6DBK6A70A9B4395F7MCPVWX
slug: no-public-blobs
title: "Storage accounts refuse public blob access"
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
    target: arm-template
    ref: policies/no-public-blobs.rego
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/adapters
tags: [sample]
---

# Storage accounts refuse public blob access

## Context

A storage account that allows public blob access can expose its containers. This decision covers ARM templates and what `bicep build` writes, including Bicep modules.

## Decision

Storage accounts refuse public blob access.

## Alternatives considered

- Review it by hand: a check runs on every change and does not get tired.

## Consequences

This check blocks, so a change that breaks it fails its job.

## Verification

`ipso check arm` evaluates `policies/no-public-blobs.rego`.
