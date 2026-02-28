#!/usr/bin/env bash
# Validates permission patterns against the local permission schema.
# Run from the repository root: bash tests/validate-permissions.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMA="$REPO_ROOT/schemas/claude-code/permission.json"
SKILL_SCHEMA="$REPO_ROOT/schemas/claude-code/skill.json"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Set up lintel config pointing to local schemas
cat > "$TMPDIR/lintel.toml" << EOF
root = true

[schemas]
"permission-*.json" = "//$SCHEMA"
"skill-*.yaml" = "//$SKILL_SCHEMA"
EOF

pass=0
fail=0
errors=""

check_valid() {
  local name="$1"
  local value="$2"
  echo "$value" > "$TMPDIR/permission-${name}.json"
  if output=$(cd "$TMPDIR" && lintel check --force "permission-${name}.json" 2>&1); then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    errors="${errors}\n  FAIL (should be valid): ${name} = ${value}\n${output}\n"
  fi
  rm -f "$TMPDIR/permission-${name}.json"
}

check_invalid() {
  local name="$1"
  local value="$2"
  echo "$value" > "$TMPDIR/permission-${name}.json"
  if output=$(cd "$TMPDIR" && lintel check --force "permission-${name}.json" 2>&1); then
    fail=$((fail + 1))
    errors="${errors}\n  FAIL (should be invalid): ${name} = ${value}\n"
  else
    pass=$((pass + 1))
  fi
  rm -f "$TMPDIR/permission-${name}.json"
}

check_skill_valid() {
  local name="$1"
  local content="$2"
  echo "$content" > "$TMPDIR/skill-${name}.yaml"
  if output=$(cd "$TMPDIR" && lintel check --force "skill-${name}.yaml" 2>&1); then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    errors="${errors}\n  FAIL (should be valid): skill ${name}\n${output}\n"
  fi
  rm -f "$TMPDIR/skill-${name}.yaml"
}

check_skill_invalid() {
  local name="$1"
  local content="$2"
  echo "$content" > "$TMPDIR/skill-${name}.yaml"
  if output=$(cd "$TMPDIR" && lintel check --force "skill-${name}.yaml" 2>&1); then
    fail=$((fail + 1))
    errors="${errors}\n  FAIL (should be invalid): skill ${name}\n"
  else
    pass=$((pass + 1))
  fi
  rm -f "$TMPDIR/skill-${name}.yaml"
}

echo "Testing permission patterns against local schema..."
echo ""

# === Bash permissions ===
echo "  Bash permissions..."
check_valid "bash-bare" '"Bash"'
check_valid "bash-exact" '"Bash(npm run build)"'
check_valid "bash-prefix-word" '"Bash(npm run *)"'
check_valid "bash-prefix-no-word" '"Bash(npm*)"'
check_valid "bash-suffix" '"Bash(* --version)"'
check_valid "bash-middle" '"Bash(git * main)"'
check_valid "bash-all" '"Bash(*)"'
check_valid "bash-complex" '"Bash(git push -u origin HEAD)"'
check_valid "bash-legacy" '"Bash(npm:*)"'
check_valid "bash-multi-word" '"Bash(* --help *)"'

# === Read permissions ===
echo "  Read permissions..."
check_valid "read-bare" '"Read"'
check_valid "read-relative" '"Read(./.env)"'
check_valid "read-glob" '"Read(*.env)"'
check_valid "read-project" '"Read(/src/**)"'
check_valid "read-home" '"Read(~/.zshrc)"'
check_valid "read-absolute" '"Read(//Users/alice/secrets/**)"'
check_valid "read-double-glob" '"Read(/src/**/*.ts)"'

# === Edit permissions ===
echo "  Edit permissions..."
check_valid "edit-bare" '"Edit"'
check_valid "edit-project" '"Edit(/src/**/*.ts)"'
check_valid "edit-home" '"Edit(~/.config/**)"'

# === Write permissions ===
echo "  Write permissions..."
check_valid "write-bare" '"Write"'
check_valid "write-project" '"Write(/src/**)"'

# === WebFetch permissions ===
echo "  WebFetch permissions..."
check_valid "webfetch-bare" '"WebFetch"'
check_valid "webfetch-domain" '"WebFetch(domain:example.com)"'

# === Simple tool permissions ===
echo "  Simple tool permissions..."
check_valid "websearch" '"WebSearch"'
check_valid "glob" '"Glob"'
check_valid "grep" '"Grep"'
check_valid "notebookedit" '"NotebookEdit"'

# === Task permissions ===
echo "  Task permissions..."
check_valid "task-bare" '"Task"'
check_valid "task-explore" '"Task(Explore)"'
check_valid "task-plan" '"Task(Plan)"'
check_valid "task-gp" '"Task(general-purpose)"'
check_valid "task-custom" '"Task(my-custom-agent)"'
check_valid "task-multi" '"Task(worker, researcher)"'

# === MCP permissions ===
echo "  MCP permissions..."
check_valid "mcp-server" '"mcp__puppeteer"'
check_valid "mcp-wildcard" '"mcp__puppeteer__*"'
check_valid "mcp-specific" '"mcp__puppeteer__puppeteer_navigate"'
check_valid "mcp-github" '"mcp__github__create_issue"'
check_valid "mcp-hyphen" '"mcp__my-server__my-tool"'

# === Invalid permissions (should fail) ===
echo "  Invalid permissions (expecting rejection)..."
check_invalid "invalid-bare" '"invalid-tool"'
check_invalid "invalid-lowercase" '"bash"'
check_invalid "invalid-case" '"BASH"'
check_invalid "invalid-unknown" '"AskUserQuestion"'
check_invalid "invalid-empty" '""'

# === Skill allowed-tools (array format via $ref chain) ===
echo "  Skill allowed-tools (array format)..."
check_skill_valid "array-bash" 'name: test
allowed-tools:
  - Bash(git push -u origin HEAD)
  - Bash(git fetch origin)'

check_skill_valid "array-mixed" 'name: test
allowed-tools:
  - Bash(git *)
  - Read
  - Grep
  - Glob
  - mcp__github__create_issue'

check_skill_valid "array-all-tools" 'name: test
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - WebFetch
  - WebSearch
  - Glob
  - Grep
  - Task
  - NotebookEdit'

# === Skill allowed-tools (string format) ===
echo "  Skill allowed-tools (string format)..."
check_skill_valid "string-csv" 'name: test
allowed-tools: Read, Grep, Glob, Bash'

check_skill_valid "string-pattern" 'name: test
allowed-tools: Read, Edit, Bash(npm run *)'

# === Skill allowed-tools (invalid array items) ===
echo "  Skill allowed-tools invalid (expecting rejection)..."
check_skill_invalid "invalid-item" 'name: test
allowed-tools:
  - Bash(git push)
  - invalid-tool'

check_skill_invalid "invalid-case-item" 'name: test
allowed-tools:
  - bash'

echo ""
echo "Results: $pass passed, $fail failed"
if [ $fail -gt 0 ]; then
  echo -e "\nFailures:$errors"
  exit 1
fi
