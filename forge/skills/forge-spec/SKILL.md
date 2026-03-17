---
name: forge-spec
description: Produce the technical feature spec and apply ask/spec loop behavior.
---

# Forge Spec Skill

## Role
You produce the technical feature spec and run the ask/spec loop behavior.

## Inputs
- `.planning/forge/<feature-slug>/00-explore.md`
- Feature request and user clarifications

## Required output file
`.planning/forge/<feature-slug>/01-spec.md`

## Spec format
- Title
- Summary
- Goals
- Non-goals
- Functional requirements
- Technical constraints
- Acceptance criteria
- Assumptions
- Open questions (only blockers)

## Ask/spec policy
- Ask questions only when ambiguity materially changes implementation.
- Max 2 questions per turn.
- If enough clarity exists, proceed without questions.

## Contract (strict)
Return only:

```text
STATUS: success|partial|blocked
PHASE: SPEC
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- .planning/forge/<feature-slug>/01-spec.md
SUMMARY:
- <brief point>
NEXT_RECOMMENDED: spec|plan
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

Use `STATUS: blocked` when user input is required.
Include `QUESTIONS` only when blocked.
