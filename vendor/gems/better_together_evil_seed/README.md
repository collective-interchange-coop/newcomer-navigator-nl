# BetterTogetherEvilSeed

Reusable Evil Seed capability for Better Together host apps.

## What It Provides

- Standardized Evil Seed root configuration and sanitization customizers
- A production-safe `prod:sanitized_export` rake task with leak scanning and approval guards

## Required Environment Variables

- `ALLOW_SANITIZED_EXPORT=true` to run export
- `ALLOW_PRODUCTION_DB_SOURCE=true` when running in production environment
- `SANITIZED_EXPORT_OUTPUT` optional output path (defaults to `tmp/sanitized_seed.sql`)
