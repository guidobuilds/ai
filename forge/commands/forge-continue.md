---
description: Continue Forge by running the next pending phase for a feature
temperature: 0.2
tools:
  task: true
  question: true
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
---

<objective>
Continue an existing Forge run by detecting the next pending phase and executing it.

Phase order:
`explore -> ask/spec loop -> plan -> build`.
</objective>

<execution_context>
@~/.config/opencode/forge/workflows/forge-continue.md
</execution_context>

<context>
Feature slug (optional): `$ARGUMENTS`
</context>

<process>
Execute the workflow from `execution_context` end-to-end.
Resolve next phase from existing artifacts under `.planning/forge/<slug>/`.
</process>
