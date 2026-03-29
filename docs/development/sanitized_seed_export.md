# Sanitized Seed Export Workflow

This document describes how to produce a sanitized SQL seed source from New to NL data while excluding personally identifiable information (PII) and sensitive operational tokens.

## Goal

Generate a portable SQL seed artifact for development and staging environments without leaking production identities, contact details, or authentication material.

## Safety Guarantees in Current Export Task

The task `prod:sanitized_export` now includes the following protections:

- Explicit operator approval requirement via `ALLOW_SANITIZED_EXPORT=true`
- Explicit production source opt-in via `ALLOW_PRODUCTION_DB_SOURCE=true` when running in production environment
- Read-only session guard: `SET default_transaction_read_only = on`
- Export graph exclusions for known PII-heavy associations (contacts, invitations, memberships)
- Deterministic redaction for translation text values and ActionText bodies
- Post-export leak scan against sensitive patterns (email, phone, IPv4, long hex tokens)
- Automatic artifact deletion on leak-scan failure

## Local Clone Workflow (Preferred)

Use this flow whenever possible.

1. Start from a local clone with synchronized schema and data source.
2. Ensure database credentials do not point at production unless explicitly intended.
3. Run:

```bash
ALLOW_SANITIZED_EXPORT=true \
SANITIZED_EXPORT_OUTPUT=tmp/sanitized_seed.sql \
bin/dc-run bundle exec rake prod:sanitized_export
```

4. Confirm success message:

- `Sanitized export completed: ...`
- `Leak scan passed with zero sensitive-pattern hits.`

5. Use `tmp/sanitized_seed.sql` as the seed source for dev/staging setup pipelines.

## Live Production Source Workflow (Restricted)

Use only when snapshot-based local workflows are not available.

### Required Controls

- Use a read-only production database role
- Use an approved maintenance window
- Keep export artifacts in restricted storage
- Enforce access logging for operators

### Command

```bash
ALLOW_SANITIZED_EXPORT=true \
ALLOW_PRODUCTION_DB_SOURCE=true \
SANITIZED_EXPORT_OUTPUT=tmp/sanitized_seed_production_source.sql \
bin/dc-run bundle exec rake prod:sanitized_export
```

## Importing into Dev or Staging

Example import:

```bash
bin/dc-run bash -lc "psql \"$DATABASE_URL\" < tmp/sanitized_seed.sql"
```

After import:

1. Run migrations if needed.
2. Run app seed tasks required for deterministic setup.
3. Run smoke tests for login, dashboard rendering, and key index/search pages.

## Operational Notes

- Export files are written under `tmp/` by default.
- `tmp/` is ignored by git in this repository.
- Avoid sharing sanitized exports over public channels.
- Rotate and expire generated artifacts according to retention policy.

## Troubleshooting

### Export blocked with approval error

Set `ALLOW_SANITIZED_EXPORT=true`.

### Export blocked in production environment

Set `ALLOW_PRODUCTION_DB_SOURCE=true` only after approval and only for controlled production-sourced runs.

### Leak scan failure

The task removes the generated SQL file and exits non-zero.

1. Review reported pattern categories.
2. Tighten Evil Seed exclusions/customizers in initializer.
3. Re-run export.

## Future Hardening Suggestions

- Add automated spec coverage for export and leak scan behavior.
- Add CI lint that blocks weakening exclusion/customization rules.
- Add structured audit logging for each export execution.
