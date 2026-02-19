## <!-- $schema: ../../../../schemas/claude-command.json -->

description: Deploy the application to the specified environment.
allowed-tools:

- Bash
- Read
  arguments:
- name: environment
  description: Target environment (staging or production)
  required: true

---

Deploy the application to the $ARGUMENTS.environment environment.
