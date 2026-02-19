# lintel-rs/catalog

Default schema catalog for [Lintel](https://github.com/lintel-rs/lintel), a JSON Schema validator for configuration files.

This catalog provides schemas for tools that don't have [SchemaStore](https://www.schemastore.org/) entries.

## Usage

This catalog is fetched automatically by Lintel. No configuration needed.

To add additional catalogs, use `registries` in `lintel.toml`:

```toml
registries = ["github:my-org/my-schemas"]
```

The `github:org/repo` shorthand resolves to `https://raw.githubusercontent.com/org/repo/main/catalog.json`.

## Catalog format

The catalog follows the [SchemaStore catalog format](https://json.schemastore.org/schema-catalog.json):

```json
{
  "$schema": "https://json.schemastore.org/schema-catalog.json",
  "version": 1,
  "schemas": [
    {
      "name": "My Schema",
      "description": "Description of the schema",
      "url": "https://raw.githubusercontent.com/org/repo/main/schemas/my-schema.json",
      "fileMatch": ["**/*.my-ext"]
    }
  ]
}
```
