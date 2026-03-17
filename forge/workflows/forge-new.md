<purpose>
Start a new Forge run with strict delegation:
1) explore
2) ask/spec loop
3) plan
4) stop before build
</purpose>

<inputs>
- Feature request: `$ARGUMENTS`
</inputs>

<response_contract>
All subagents must return this format:

```text
STATUS: success|partial|blocked
PHASE: EXPLORE|SPEC|PLAN|BUILD
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- <path>
SUMMARY:
- <brief point>
NEXT_RECOMMENDED: explore|spec|plan|build|none
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

Rules:
- `QUESTIONS` is required only when `STATUS: blocked`.
- If malformed, request one contract-only reformat using the same task_id.
- If malformed again, stop with an actionable error.
</response_contract>

<clarification_policy>
Spec clarification loop:
- Ask only the exact questions returned by subagent.
- Resume same `task_id` with user answers.
- Max clarification rounds: 3.
- After round 3, force explicit assumptions and continue.
</clarification_policy>

<process>
## Step 1: Validate input

If `$ARGUMENTS` is empty:
- Ask for a short feature description.
- Stop.

## Step 2: Run explore

```text
Task(
  description="Forge explore",
  subagent_type="forge-explore",
  prompt="Explore feature request: $ARGUMENTS. Follow your skill instructions. Return the exact response contract."
)
```

Capture `FEATURE_SLUG` and ensure artifact `.planning/forge/<slug>/00-explore.md` exists.

Ask user checkpoint:
- Continue to spec loop?

## Step 3: Run ask/spec loop

Start spec:

```text
Task(
  description="Forge spec",
  subagent_type="forge-spec",
  prompt="Create technical spec for feature request: $ARGUMENTS using .planning/forge/ context. Follow your skill instructions and return exact response contract."
)
```

Loop behavior:
- If `STATUS: blocked`, ask returned questions and wait.
- Resume same `task_id` with `User answers: ...`.
- Repeat until `STATUS: success`.

Capture artifact `.planning/forge/<slug>/01-spec.md`.

Ask user checkpoint:
- Continue to planning?

## Step 4: Run plan

```text
Task(
  description="Forge plan",
  subagent_type="forge-plan",
  prompt="Create implementation plan from 00-explore.md and 01-spec.md. Follow your skill instructions and return exact response contract."
)
```

Capture artifact `.planning/forge/<slug>/02-plan.md`.

## Step 5: Stop before build

Report:
- `00-explore.md` path
- `01-spec.md` path
- `02-plan.md` path
- Next command: `/forge-continue <feature-slug>`
</process>
