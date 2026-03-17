<purpose>
Continue a Forge run by executing the next pending phase based on artifacts.

Phase order:
1) explore
2) ask/spec loop
3) plan
4) build
</purpose>

<inputs>
- Optional feature slug: `$ARGUMENTS`
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

<process>
## Step 1: Resolve feature slug

If `$ARGUMENTS` is non-empty, use it as slug.

If empty:
- Inspect `.planning/forge/`.
- If exactly one feature folder exists, use it.
- If multiple exist, ask user to pick one slug and stop.

## Step 2: Resolve next phase by artifacts

Given `.planning/forge/<slug>/`:
- If `00-explore.md` missing: next is `explore`.
- Else if `01-spec.md` missing: next is `spec`.
- Else if `02-plan.md` missing: next is `plan`.
- Else if `03-build-log.md` missing: next is `build`.
- Else: report run complete and stop.

## Step 3: Execute next phase

### If next is explore

```text
Task(
  description="Forge explore",
  subagent_type="forge-explore",
  prompt="Continue Forge for feature slug <slug>. Produce or refresh 00-explore.md. Follow your skill and return exact response contract."
)
```

### If next is spec

```text
Task(
  description="Forge spec",
  subagent_type="forge-spec",
  prompt="Continue Forge for feature slug <slug>. Use 00-explore.md and produce 01-spec.md. Follow your skill and return exact response contract."
)
```

If spec returns `STATUS: blocked`, run ask/spec loop:
- Ask provided questions.
- Resume same `task_id` with user answers.

### If next is plan

```text
Task(
  description="Forge plan",
  subagent_type="forge-plan",
  prompt="Continue Forge for feature slug <slug>. Use 00-explore.md and 01-spec.md to produce 02-plan.md. Follow your skill and return exact response contract."
)
```

### If next is build

Before build, ask one checkpoint:
- Start build now?

If yes:

```text
Task(
  description="Forge build",
  subagent_type="forge-build",
  prompt="Continue Forge for feature slug <slug>. Implement 02-plan.md and write 03-build-log.md. Follow your skill and return exact response contract."
)
```

If no:
- stop and report pending build.

## Step 4: Report outcome

Report executed phase, written artifacts, and next suggested command:
- `/forge-continue <slug>`
</process>
