# fledge-hello-swift

Example fledge plugin written in Swift, demonstrating the **fledge-v1** protocol. Exercises every message type in a single interactive walkthrough.

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
fledge plugin install ./path/to/fledge-hello-swift
fledge hello-swift
```

## Testing directly

```bash
swift build -c release
echo '{"type":"init","protocol":"fledge-v1","args":[],"project":null,"plugin":{"name":"fledge-hello-swift","version":"0.1.0","dir":"/tmp"},"fledge":{"version":"0.9.0"}}' \
  | .build/release/fledge-hello-swift
```

## Writing your own plugin in Swift

1. Create a Swift package with no external dependencies (Foundation is enough)
2. Define Codable types for each message you need
3. Read JSON lines from stdin, write JSON lines to stdout
4. Use stderr for debug output (fledge never captures it)
5. Add a `plugin.toml` with `protocol = "fledge-v1"`
