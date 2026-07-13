---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-the-swift-hello-fledge-plugi
artifact: testing
---

# Testing

Local acceptance requires the Fledge verification lane, strict 100% coverage, four installed integrations, a healthy Trust doctor, and a clean diff.

## Requirement Evidence

- `REQ-hello-swift-001`: `swift build` and `swift build -c release` type-check initialization, response decoding, and stream separation.
- `REQ-hello-swift-002`: both Swift builds compile every outbound Codable message type and schema tag.
- `REQ-hello-swift-003`: both Swift builds validate correlation identifiers and synchronous response consumption.
- `REQ-hello-swift-004`: both Swift builds validate explicit startup and encoding error paths.

Hosted acceptance requires both the new macOS `trust` job and existing debug/release build job to pass.
