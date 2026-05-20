#!/usr/bin/env bash
# Deploy status.json to Cloudflare Pages (project: pepjournal-status).
# Run from this directory after editing status.json.
set -euo pipefail

cd "$(dirname "$0")"

# Sanity: status.json must be valid JSON before we ship it to users.
python3 -m json.tool status.json > /dev/null

npx wrangler@latest pages deploy . \
  --project-name=pepjournal-status \
  --branch=main \
  --commit-dirty=true
