---
description: Perform a read-only code review using the code-review skill
agent: ask
---
Use the `code-review` skill and its referenced checklist to review: ${input:scope:files, folder, or leave empty for current diff}

If no scope is given, inspect the uncommitted changes. If there is no Git repository or no changes, ask which files to review. Do not edit files or commit.
