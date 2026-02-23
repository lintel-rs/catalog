# lintel-rs/catalog

Default schema catalog for [Lintel](https://github.com/lintel-rs/lintel), a JSON Schema validator for configuration files.

**Catalog URL:** https://catalog.lintel.tools

This catalog provides schemas for tools that don't have [SchemaStore](https://www.schemastore.org/) entries, including Claude Code, Lintel, Clippy, kysely-codegen, sellers.json, and more. It also imports and organizes schemas from SchemaStore for GitHub Actions, Rust tooling, and other ecosystems.

## Usage

This catalog is fetched **automatically** by Lintel — no configuration needed. Lintel merges it with [SchemaStore](https://www.schemastore.org/) to provide schema validation out of the box.

The generated catalog is published at:

```
https://catalog.lintel.tools/catalog.json
```

Individual schemas are available at:

```
https://catalog.lintel.tools/<group>/<schema>.json
```

For example: https://catalog.lintel.tools/kysely/kysely-codegen.json

### Using as an additional registry

If you're running your own Lintel catalog and want to include these schemas, add it as a registry in `lintel.toml`:

```toml
registries = ["https://catalog.lintel.tools/catalog.json"]
```

### Disabling the default catalog

To use only SchemaStore (without this catalog), set `no-default-catalog` in `lintel.toml`:

```toml
no-default-catalog = true
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add new schemas.
