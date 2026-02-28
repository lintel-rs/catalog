## <!-- $schema: ../../../../../schemas/claude-code/skill.json -->

name: pr-create
description: Create pull requests using the CLI. Use when the user asks to create a PR, open a pull request, or submit a PR.
allowed-tools:

- Bash(git push -u origin HEAD)
- Bash(git fetch origin)
- Bash(git log \*)
- Bash(git diff \*)
- Bash(npm run \*)
- Bash(\* --version)
- Bash(_ --help _)
- Read
- Read(/src/\*\*)
- Read(./.env)
- Read(~/.zshrc)
- Edit
- Edit(/src/\*_/_.ts)
- Write
- Write(/src/\*\*)
- Grep
- Glob
- WebFetch
- WebFetch(domain:example.com)
- WebSearch
- Task
- Task(Explore)
- Task(Plan)
- Task(general-purpose)
- Task(worker, researcher)
- NotebookEdit
- mcp**puppeteer**puppeteer_navigate
- mcp**github**create_issue
- mcp\_\_puppeteer
- mcp**puppeteer**\*

---

Create a pull request for the current branch.
