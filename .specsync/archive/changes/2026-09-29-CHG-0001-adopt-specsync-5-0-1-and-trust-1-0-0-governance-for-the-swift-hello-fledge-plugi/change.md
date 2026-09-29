---
id: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-the-swift-hello-fledge-plugi
state: archived
type: migration
base_commit: dc875856279002d9d34ade77f906563d91c0652f
---

# Adopt SpecSync 5.0.1 and Trust 1.0.0 governance for the Swift Hello Fledge plugin

## Intent

Adopt SpecSync 5.0.1 and Trust 1.0.0 governance for the Swift Hello Fledge plugin

## Affected Canonical Specs

- `hello-swift`

## Acceptance Criteria

- SpecSync strict coverage is 100%.
- Claude, Cursor, Codex, and Gemini integrations are installed.
- Trust doctor and verification pass.
- Swift debug and release builds plus manifest validation remain green.

## No-spec Rationale

Not applicable

## Migration Note

Migrated by hand to SpecSync 6 per Leif's decision (2026-09-28); the 6.0.0 tool refused to archive this legacy record (`` exact-only delivery input `.github/workflows/trust.yml` changed after acceptance and requires an audited reopen; run `specsync change reopen CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-the-swift-hello-fledge-plugi` to re-verify the accepted change, or supersede it from a later change under a module granted the path by `owns` in `.specsync/config.toml` ``).

- Workflow v1 (SpecSync 5) record, accepted on 2026-07-18 by the closing approval already stored in `approvals.json`. SpecSync 6.0.0 reports its accepted evidence as stale, for the reason quoted above.
- Moved by hand from `.specsync/changes/CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-the-swift-hello-fledge-plugi/` into the layout `specsync change archive` writes: `accepted-state.json` is the unchanged accepted `state.json`, `state.json` is marked `archived`, and this file's front matter says `archived`.
- `approvals.json`, `verification.json`, `verification-attempts.json` and every other artifact are the original SpecSync 5 evidence, unchanged. `verification.json` verifies commit `40602796c5baa8b479c00710e6513ce293d69e54`, not the tree this record was archived from.
- This migration added no verification evidence, test result, attempt history, or approval. It is a manual migration, not a fresh re-verification.
- Closing it through the tool takes `specsync change reopen`, `specsync change verify`, then `specsync change accept`, which writes a new closing approval. Per Leif's decision it was archived by hand instead, so no reopen or new approval is recorded.
