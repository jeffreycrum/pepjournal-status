# pepjournal-status

Service-status JSON for the [PepJournal](https://www.pepjournal.com) iOS app.

The app fetches `status.json` every 5 minutes (and on each foreground) from a Railway-independent host — this repo, served via GitHub Pages — so a banner can be raised when the backend is degraded or down.

## Live URL

After GitHub Pages is enabled on the `main` branch root:

```
https://jeffreycrum.github.io/pepjournal-status/status.json
```

This URL is configured in the iOS app via the `STATUS_JSON_URL` key in `Info.plist`.

## Raising a banner during an outage

Edit `status.json`, commit, push. Users see the banner within ~5 minutes (or immediately on app foreground).

```json
{
  "active": true,
  "id": "2026-05-19-railway-outage",
  "message": "We're experiencing a service issue. Some features may be unavailable.",
  "severity": "warning",
  "dismissible": true
}
```

### Fields

| Field | Type | Notes |
|---|---|---|
| `active` | bool | Gates display. Set to `false` to clear the banner. |
| `id` | string | **Unique per incident.** Once a user dismisses an `id`, they won't see it again — but a new `id` will show. Use a date-prefixed slug, e.g. `2026-05-19-railway-outage`. |
| `message` | string | One or two sentences. Plain text, no markdown. |
| `severity` | `info` \| `warning` \| `critical` | Drives color and icon. |
| `dismissible` | bool | `false` for sticky banners users can't hide (use sparingly). |

## Resolving an incident

Set `active: false`. Leave the rest in place as a record, or reset:

```json
{
  "active": false,
  "id": "none",
  "message": "",
  "severity": "info",
  "dismissible": true
}
```

## Design notes

- **Hosted independently of Railway** — when the backend is down, this stays up. That's the whole point.
- **Silent failure on the client** — if this repo / GitHub Pages is also down, the app shows no error to the user; the banner just doesn't appear.
- **No auth, no PHI** — `status.json` is fetched by every app install, so it must be publicly readable and contain no sensitive data.
- **Cache-busting** — the iOS client uses `reloadIgnoringLocalCacheData` and GitHub Pages serves with a short cache TTL, so updates propagate quickly.

## Future: custom subdomain

To move to `status.pepjournal.com`:
1. Add a `CNAME` file at the repo root with `status.pepjournal.com`
2. Add a CNAME DNS record at the registrar: `status` → `jeffreycrum.github.io`
3. Update `STATUS_JSON_URL` in the iOS build config to `https://status.pepjournal.com/status.json`

No app update needed — `STATUS_JSON_URL` is read at runtime from `Info.plist`.
