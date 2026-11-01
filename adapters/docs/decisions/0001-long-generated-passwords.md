---
edr: 1
id: 01M6DBK6A6Y87Z2173D5JAMSTV
slug: long-generated-passwords
title: "Generated passwords have at least 16 characters"
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
    target: pulumi-preview
    ref: policies/long-generated-passwords.rego
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/examples/tree/main/adapters
tags: [sample]
---

# Generated passwords have at least 16 characters

## Context

A short generated password is easy to guess, and one number in a program sets its length.

## Decision

Generated passwords have at least 16 characters.

## Alternatives considered

- Review it by hand: a check runs on every change and does not get tired.

## Consequences

This check blocks, so a change that breaks it fails its job.

## Verification

`ipso check pulumi` evaluates `policies/long-generated-passwords.rego`.
