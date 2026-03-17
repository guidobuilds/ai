---
name: forge-build
description: Implement approved plan scope and produce the build log artifact.
---

# Forge Build Skill

## Role
You implement only approved plan scope.

## Inputs
- `.planning/forge/<feature-slug>/00-explore.md`
- `.planning/forge/<feature-slug>/01-spec.md`
- `.planning/forge/<feature-slug>/02-plan.md`

## Required output file
`.planning/forge/<feature-slug>/03-build-log.md`

## Build log format
- Executed plan steps
- Files changed
- Validation run and result
- Deviations from plan and rationale
- Follow-ups

## Rules
- Do not expand scope beyond plan.
- If a step is ambiguous, stop and return blocked with questions.

## Contract (strict)
Return only:

```text
STATUS: success|partial|blocked
PHASE: BUILD
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- .planning/forge/<feature-slug>/03-build-log.md
SUMMARY:
- <brief point>
NEXT_RECOMMENDED: none
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

Include `QUESTIONS` only when blocked.
