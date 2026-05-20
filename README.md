# pepjournal-status

Service-status JSON for the [PepJournal](https://www.pepjournal.com) iOS app.

The app fetches `status.json` every 5 minutes (and on each foreground) from a Railway-independent host — **Cloudflare Pages**, served via `status.pepjournal.com` — so a banner can be raised when the backend is degraded or down.

## Live URL

```
https://status.pepjournal.com/status.json
```

Configured in the iOS app via the `STATUS_JSON_URL` build setting in `Config/Secrets.base.xcconfig`, exposed at runtime through `Info.plist`.

## Updating the banner (during or after an outage)

Edit `status.json`, then deploy:

```bash
./deploy.sh
```

That runs `wrangler pages deploy` against the `pepjournal-status` Cloudflare Pages project. Updates go live in ~5 seconds. Users see them within their next 5-minute poll (or immediately on app foreground).

### Banner schema

```json
{
  "active": true,
  "id": "2026-05-19-railway-outage",
  "message": "We're experiencing a service issue. Some features may be unavailable.",
  "severity": "warning",
  "dismissible": true
}
```

| Field | Type | Notes |
|---|---|---|
| `active` | bool | Gates display. `false` clears the banner. |
| `id` | string | **Unique per incident.** Once a user dismisses an `id`, they won't see it again — but a new `id` will show. Use a date-prefixed slug, e.g. `2026-05-19-railway-outage`. |
| `message` | string | One or two sentences. Plain text. |
| `severity` | `info` \| `warning` \| `critical` | Drives color and icon. |
| `dismissible` | bool | `false` for sticky banners (use sparingly). |

### Resolving an incident

Set `active: false` and re-deploy. Optional reset:

```json
{
  "active": false,
  "id": "none",
  "message": "",
  "severity": "info",
  "dismissible": true
}
```

## Why Cloudflare Pages?

- **Independent of Railway** — the entire point. If our backend is down, this stays up.
- **CF global CDN** — fast everywhere; no cold-start.
- **TLS handled by CF** — Universal SSL, auto-renewing.
- **No build step** — static files, deploy is just upload.
- **Free** for the traffic profile (every app install polls every 5 min — bandwidth is trivial).

## First-time setup notes (already done, here for reference)

- Cloudflare Pages project: `pepjournal-status`
- Production branch: `main`
- Custom domain: `status.pepjournal.com` (proxied CNAME → `pepjournal-status.pages.dev`)
- Cert provisioned by Google via Cloudflare
- GitHub Pages was used initially but is now disabled — Cloudflare is the sole host

## Client behavior

- iOS `StatusService` uses `URLSession.shared` directly (NOT `APIClient`) so it has no dependency on the backend.
- Cache policy: `reloadIgnoringLocalCacheData` — every poll hits CF's edge fresh.
- Silent failure: if this domain is unreachable, no banner shows and no error surfaces to the user. The app just behaves as if there's no active incident.
- Per-incident dismiss: persisted in `UserDefaults` under `dismissedStatusBannerIDs`. A new `id` is required to re-show after dismiss.

## Source

- iOS implementation: `glp1-companion-frontend/Services/StatusService.swift`
- Banner view: `glp1-companion-frontend/Views/Common/StatusBannerView.swift`
- Tests: `glp1-companion-frontend/Tests/StatusServiceTests.swift`
