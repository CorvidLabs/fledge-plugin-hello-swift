---
module: hello-swift
version: 1
status: active
files:
  - Sources/main.swift

db_tables: []
depends_on: []
---

# Hello-swift

## Purpose

Provide the Swift reference implementation of the `fledge-v1` JSON-lines plugin protocol, demonstrating every supported interactive and one-way message type.

## Public API

| Surface | Behavior |
|---------|----------|
| hello-swift | Consume a fledge-v1 initialization message and demonstrate all protocol message variants. |

## Invariants

1. Standard input and output contain one JSON object per protocol line.
2. Diagnostics use standard error and do not contaminate protocol output.
3. Request identifiers are unique within the process and responses are consumed before continuing.
4. Outbound message types serialize to the fledge-v1 snake-case names.
5. Missing or invalid initialization input exits non-zero.
6. The manifest declares the fledge-v1 protocol and release binary.

## Behavioral Examples

```
Given a valid initialization message and host responses
When Fledge launches the Swift example
Then it demonstrates logging, output, prompts, selection, progress, storage, execution, and metadata through JSON lines
```

## Error Cases

| Error | When | Behavior |
|-------|------|----------|
| Missing init | Standard input closes before initialization | Report the failure and exit non-zero. |
| Invalid JSON | A typed message cannot be decoded | Return no typed value and fail the required startup path. |
| Encoding failure | An outbound message cannot be serialized | Write a diagnostic to standard error without corrupting protocol output. |

## Dependencies

- Swift 5.9 or later
- Foundation
- Fledge host implementing `fledge-v1`

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1 | 2026-07-12 | Document the existing Swift fledge-v1 reference behavior for SpecSync 5 adoption. |
