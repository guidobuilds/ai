---
description: Run SSD quick cycle (spec -> plan), then stop before build
temperature: 0.2
tools:
  task: true
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  question: true
---

<objective>
Run a short SSD cycle for small, low-risk work:
`ssd-spec (quick) -> ssd-plan (quick)`.

Use this for tiny refactors, simple bug fixes, and small tweaks.
Stop before build by default.
</objective>

<execution_context>
@~/.config/opencode/ssd/workflows/ssd-quick-task.md
</execution_context>

<context>
Quick task request: `$ARGUMENTS`
</context>

<process>
Execute the workflow in `execution_context` end-to-end.
Preserve all gates:
- question-driven clarification loops (when needed)
- strict status contract parsing
- malformed-output retry policy
- quick-scope guardrails and fallback to `/ssd-new-feature` when risky
- ask before building; do not auto-build
</process>
