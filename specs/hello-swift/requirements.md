---
spec: hello-swift.spec.md
---

## User Stories

- As a Swift plugin author, I want a typed reference for every fledge-v1 interaction.

## Acceptance Criteria

### REQ-hello-swift-001

The plugin SHALL decode initialization and response messages while keeping protocol output separate from diagnostics.

Acceptance Criteria
- Debug and release builds compile the typed initialization and response decoders.
- Protocol output and diagnostics use separate standard streams.

### REQ-hello-swift-002

The example SHALL encode every supported outbound message type using the fledge-v1 JSON schema.

Acceptance Criteria
- Debug and release builds compile every outbound Codable message type.
- Encoded message tags use the fledge-v1 schema names.

### REQ-hello-swift-003

Every request SHALL use a unique correlation identifier and consume its host response before continuing.

Acceptance Criteria
- Request identifiers are unique within the process.
- A host response is decoded before the next request proceeds.

### REQ-hello-swift-004

Missing initialization and encoding failures SHALL not produce a false successful protocol completion.

Acceptance Criteria
- Missing initialization exits non-zero.
- Encoding failures emit a diagnostic without corrupting protocol output.

## Constraints

- The example targets macOS 13+ and relies on Fledge for rendering, storage, execution, and metadata.

## Out of Scope

- Defining a new protocol version or publishing a reusable Swift client library.
