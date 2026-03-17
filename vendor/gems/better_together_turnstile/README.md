# BetterTogetherTurnstile

Reusable Cloudflare Turnstile integration for Better Together host apps.

## What It Provides

- Default Turnstile configuration using environment variables
- A controller concern that plugs into Better Together registration captcha hooks

## Environment Variables

- `CLOUDFLARE_TURNSTILE_SITE_KEY`
- `CLOUDFLARE_TURNSTILE_SECRET_KEY`
