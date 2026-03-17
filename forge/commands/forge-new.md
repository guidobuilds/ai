---
description: Run Forge flow (explore -> spec loop -> plan), then stop before build
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
Run the Forge orchestration flow for a new feature:
`forge-explore -> ask/spec loop -> forge-plan`, then pause before build.
</objective>

<execution_context>
@~/.config/opencode/forge/workflows/forge-new.md
</execution_context>

<context>
Feature request: `$ARGUMENTS`
</context>

<process>
Execute the workflow from `execution_context` end-to-end.
Enforce strict contracts, clarification loops, and explicit user checkpoints.
</process>
