---
spec: hello-swift.spec.md
---

## Context

This repository complements the Bash and Rust references with Foundation Codable message models for Swift plugin authors.

## Related Modules

- Fledge plugin host and fledge-v1 protocol.
- `plugin.toml` command registration.

## Design Decisions

- Use concrete Codable message types so protocol JSON remains explicit.
- Flush standard output after every message to preserve request ordering.
