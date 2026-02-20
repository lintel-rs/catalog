# Claude Code Schemas

JSON Schemas for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) frontmatter — agents, skills, and commands.

These schemas validate the YAML frontmatter in your `.claude/` markdown files, catching typos, invalid field values, and missing required fields before they cause silent failures.

## Schemas

| Schema                               | File patterns                              | Docs                                                                       |
| ------------------------------------ | ------------------------------------------ | -------------------------------------------------------------------------- |
| [agent.json](agent.json)             | `.claude/agents/*.md`                      | [Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)    |
| [skill.json](skill.json)             | `.claude/skills/*.md`, `skills/*/SKILL.md` | [Skills](https://docs.anthropic.com/en/docs/claude-code/skills)            |
| [command.json](command.json)         | `.claude/commands/*.md`                    | [Skills](https://docs.anthropic.com/en/docs/claude-code/skills)            |
| [plugin.json](plugin.json)           | `.claude-plugin/plugin.json`               | [Plugins reference](https://code.claude.com/docs/en/plugins-reference)     |
| [marketplace.json](marketplace.json) | `.claude-plugin/marketplace.json`          | [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) |

## Validate with Lintel

[Lintel](https://github.com/lintel-rs/lintel) validates config files against JSON Schemas. It supports YAML, JSON, TOML, and markdown frontmatter out of the box.

### Install

```sh
# Nix (recommended)
nix profile install github:lintel-rs/lintel

# Cargo
cargo install lintel
```

### Run

```sh
# Validate all matched files in the current project
lintel check

# Validate a specific file
lintel check .claude/agents/researcher.md
```

Lintel automatically fetches schemas from the [lintel-rs/catalog](https://github.com/lintel-rs/catalog) and matches them to files by path pattern. No configuration needed — just run `lintel check` in any project with `.claude/` files.

### Example output

```
$ lintel check .claude/agents/researcher.md
.claude/agents/researcher.md
  ✗ Additional property 'colour' is not allowed  [agent.json]
  ✗ 'dark-blue' is not one of ['opus', 'sonnet', 'haiku', 'inherit']  at /model  [agent.json]
```

### CI integration

Add Lintel to your CI pipeline to catch frontmatter errors on every push:

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  lintel:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v31
      - run: nix profile install github:lintel-rs/lintel
      - run: lintel check
```

### Pre-commit hook with devenv

```nix
# devenv.nix
{ inputs, pkgs, ... }:
let
  lintel = inputs.lintel.packages.${pkgs.system}.default;
in {
  git-hooks.hooks.lintel = {
    enable = true;
    name = "lintel";
    entry = "${lintel}/bin/lintel check";
    types_or = [ "json" "yaml" "markdown" ];
  };
}
```

## Inline schema override

You can pin a specific file to a schema with an HTML comment before the frontmatter:

```markdown
## <!-- $schema: https://raw.githubusercontent.com/lintel-rs/catalog/master/schemas/claude-code/agent.json -->

name: my-agent
description: Does things.

---

System prompt here.
```
