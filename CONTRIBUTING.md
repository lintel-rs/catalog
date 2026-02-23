# Contributing to lintel-rs/catalog

This catalog provides JSON Schemas for tools and configuration files that don't have [SchemaStore](https://www.schemastore.org/) entries. Contributions of new schemas and improvements to existing ones are welcome.

## Adding a new schema

### 1. Choose or create a group

Schemas are organized into groups in `lintel-catalog.toml`. Pick an existing group or add a new one:

```toml
[groups.my-group]
name = "My Group"
description = "Short description of what this group covers"
```

### 2. Create the schema file

Place your schema at `schemas/<group>/<schema-key>.json`. Use [JSON Schema draft 2020-12](https://json-schema.org/draft/2020-12/schema):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "my-config.toml",
  "description": "Short description with a **link to the official docs**.",
  "type": "object",
  "properties": {
    ...
  }
}
```

**Guidelines:**

- Use markdown in `description` fields (links, bold, bullet lists) but **not** tables
- Include `description` on every property, not just the root
- Use `examples` where they help clarify expected values
- Use `const`, `enum`, `default`, `format`, and conditional validation (`if`/`then`) where the spec defines them
- Don't set `additionalProperties: false` unless the spec explicitly forbids extra keys
- Base the schema on the **official specification** — link to it in the root `description`

### 3. Register the schema in the catalog

Add an entry to `lintel-catalog.toml` under the appropriate group:

```toml
[groups.my-group.schemas.my-schema]
name = "my-config.toml"
description = "Short description for the catalog listing"
file-match = [
  "my-config.toml",
  "**/my-config.toml",
]
```

The `file-match` patterns determine which files Lintel will automatically validate against this schema. Use globs that match the conventional file locations.

For schemas hosted externally (not in this repo), add a `url` field:

```toml
[groups.my-group.schemas.my-schema]
url = "https://example.com/schema.json"
name = "my-config.toml"
description = "Short description"
file-match = ["my-config.toml"]
```

### 4. Add tests (optional but recommended)

Place example files under `tests/<group>/` that should validate against your schema.

## Improving an existing schema

- Add missing fields, fix types, improve descriptions
- Reference the official specification for accuracy
- Keep descriptions concise and useful — they're shown in editor hovers

## Catalog structure

```
lintel-catalog.toml          # catalog config: sources, groups, schema entries
schemas/
  ads/
    sellers.json              # schema files organized by group
  claude-code/
    agent.json
    ...
  rust/
    clippy.json
```

The catalog builder (`lintel-catalog-builder`) reads `lintel-catalog.toml` and generates the published catalog. It also pulls in schemas from configured sources like SchemaStore.
