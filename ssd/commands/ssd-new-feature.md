---
description: Run SSD spec -> deepdive -> plan (stops before build)
temperature: 0.2
tools:
  task: true
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
---

<objective>
Run SSD orchestration for non-trivial work:
`ssd-spec -> ssd-deepdive -> ssd-plan`, then stop before build.
</objective>

<execution_context>
@~/.config/opencode/ssd/workflows/ssd-new-feature.md
</execution_context>

<context>
Feature request: `$ARGUMENTS`
</context>

<process>
Execute the workflow in `execution_context` end-to-end.
Preserve all gates:
- question-driven clarification loops (when needed)
- strict status contract parsing
- malformed-output retry policy
- complexity/risk-aware deepdive mode
- stop before build with next-step instructions
</process>
