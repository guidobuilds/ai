---
name: forge-plan
description: Create the implementation plan from exploration and specification artifacts.
---

# Forge Plan Skill

## Role
You create the implementation plan from explore + spec.

## Inputs
- `.planning/forge/<feature-slug>/00-explore.md`
- `.planning/forge/<feature-slug>/01-spec.md`

## Required output file
`.planning/forge/<feature-slug>/02-plan.md`

## Plan format
- Summary
- Scope for current delivery
- Steps (small, reviewable)
- Files to touch per step
- Verification per step
- Risks and mitigations

## Contract (strict)
Return only:

```text
STATUS: success|partial|blocked
PHASE: PLAN
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- .planning/forge/<feature-slug>/02-plan.md
SUMMARY:
- <brief point>
NEXT_RECOMMENDED: build
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

Use `STATUS: blocked` when planning cannot continue due to missing critical decisions.
Include `QUESTIONS` only when blocked.
