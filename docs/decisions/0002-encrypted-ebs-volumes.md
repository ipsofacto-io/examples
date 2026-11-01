---
edr: 1
id: 01M6C5G8KCZRD8W1WJ5QJ60G5H
slug: encrypted-ebs-volumes
title: "EBS volumes are encrypted"
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
    ref: ipso:aws/ebs-encrypted
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/ipso-action
tags: [storage, sample]
---

# EBS volumes are encrypted

## Context

An unencrypted volume keeps its data readable on a snapshot that leaves the account.

## Decision

Every EBS volume is encrypted.

## Alternatives considered

- Turn on account-wide default encryption only: it does not cover an account the setting has not reached.

## Consequences

This check warns while existing volumes move, so the job stays green and a warning appears in code scanning. The sample plan breaks it on purpose, so that the alert is there to look at.

## Verification

`ipso check plan` evaluates the built-in `aws/ebs-encrypted` template on every Terraform plan.
