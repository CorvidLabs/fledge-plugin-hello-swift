# fledge-plugin-hello-swift

**Reference implementation** for writing fledge plugins in Swift.

This plugin demonstrates the complete **fledge-v1** protocol by exercising every message type in a single interactive walkthrough. Use it as a starting point when building your own Swift-based fledge plugins.

[![CI](https://github.com/CorvidLabs/fledge-plugin-hello-swift/actions/workflows/ci.yml/badge.svg)](https://github.com/CorvidLabs/fledge-plugin-hello-swift/actions/workflows/ci.yml)

## Why Swift?

Swift is a natural fit for fledge plugins on macOS: zero external dependencies (Foundation handles JSON), fast compile times, and first-class structured concurrency. This reference implementation shows you can build a fully-featured plugin with just the standard library.

## Message types demonstrated

| # | Type | Direction | What happens |
|---|------|-----------|-------------|
| 1 | `log` | plugin -> fledge | Colored structured logging |
| 2 | `output` | plugin -> fledge | Raw text passthrough |
| 3 | `prompt` | plugin -> fledge -> plugin | Ask for text input with validation |
| 4 | `confirm` | plugin -> fledge -> plugin | Yes/no dialog |
| 5 | `select` | plugin -> fledge -> plugin | Pick one from a list |
| 6 | `multi_select` | plugin -> fledge -> plugin | Pick multiple from a list |
| 7 | `progress` | plugin -> fledge | Determinate progress bar |
| 8 | `store` / `load` | plugin -> fledge | Key-value persistence roundtrip |
| 9 | `exec` | plugin -> fledge -> plugin | Sandboxed shell command |
| 10 | `metadata` | plugin -> fledge -> plugin | Project context query |
| 11 | `progress` (spinner) | plugin -> fledge | Indeterminate spinner |

## Building

```bash
swift build -c release
```

Or with fledge:

```bash
fledge run build
```

## Installing

```bash
fledge plugins install CorvidLabs/fledge-plugin-hello-swift
fledge hello-swift
```

## Testing directly

```bash
swift build -c release
echo '{"type":"init","protocol":"fledge-v1","args":[],"project":null,"plugin":{"name":"fledge-hello-swift","version":"0.1.0","dir":"/tmp"},"fledge":{"version":"0.9.0"}}' \
  | .build/release/fledge-hello-swift
```

## Writing your own plugin in Swift

This repo is designed to be cloned and modified. Here is the pattern:

1. Create a Swift package with no external dependencies (Foundation is enough for JSON)
2. Define `Codable` types for each message you need (see `Sources/main.swift`)
3. Read JSON lines from stdin, write JSON lines to stdout
4. Use stderr for debug output (fledge never captures it)
5. Add a `plugin.toml` with `protocol = "fledge-v1"` and a `[[commands]]` entry pointing to your binary
6. Publish to GitHub as `your-org/fledge-plugin-{name}` so users can install with `fledge plugins install`

## Project structure

```
.
├── Package.swift       # Swift package manifest (macOS 13+, Swift 5.9+)
├── Sources/
│   └── main.swift      # Plugin entry point — all protocol handling
├── plugin.toml         # Fledge plugin manifest
└── fledge.toml         # Fledge task definitions (build/dev/test/clean)
```

## License

MIT
