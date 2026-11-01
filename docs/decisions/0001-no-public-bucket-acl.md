---
edr: 1
id: 01M6C5G8KCHJP5Y0HKRDA4CXAH
slug: no-public-bucket-acl
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
    target: terraform-plan
    ref: ipso:aws/s3-no-public-acl
waivers: []
sources:
  - type: spec
    url: https://github.com/ipsofacto-io/ipso-action
tags: [storage, sample]
---

# S3 buckets have no public ACL

## Context

A public bucket ACL exposes every object in the bucket, and one line in a Terraform file is enough to set it.

## Decision

No S3 bucket uses a public ACL.

## Alternatives considered

- Review every bucket by hand: a plan check runs on every change and does not get tired.

## Consequences

A public website needs a reviewed waiver. This check blocks, so the job fails when a plan breaks it.

## Verification

`ipso check plan` evaluates the built-in `aws/s3-no-public-acl` template on every Terraform plan.
