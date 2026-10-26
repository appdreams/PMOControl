# Settings & Administration API

**Status:** Approved

## Areas

Tenant settings, users/memberships, access grants, taxonomies, RAG
rules, integrations and AI/BYOK configuration.

## Security

Every sensitive setting change is authorized and audited.

## Secrets

API returns only masked/metadata representation. Raw stored secrets are
never returned.

## Access changes

Membership/role/scope revocation must affect subsequent authorization
promptly.
