---
name: forge-explore
description: Explore the requested feature and write the baseline exploration artifact.
---

# Forge Explore Skill

## Role
You run the explore phase and write a compact deepdive baseline.

## Inputs
- Feature request from orchestrator prompt.
- Repository code and docs.

## Required output file
`.planning/forge/<feature-slug>/00-explore.md`

## Explore content
- Problem framing
- Current architecture touchpoints
- Constraints and risks
- Open decisions that impact spec

## Contract (strict)
Return only:

```text
STATUS: success|partial|blocked
PHASE: EXPLORE
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- .planning/forge/<feature-slug>/00-explore.md
SUMMARY:
- <brief point>
NEXT_RECOMMENDED: spec
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

Use `STATUS: blocked` only if missing information blocks meaningful exploration.
Include `QUESTIONS` only when blocked.
