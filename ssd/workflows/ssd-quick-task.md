<purpose>
Run a short SSD cycle for small, low-risk tasks:
1) spec (quick)
2) plan (quick)
3) ask before build

No deepdive by default.
Fallback to `/ssd-new-feature` when work is not quick-safe.
</purpose>

<inputs>
- Quick task request: `$ARGUMENTS`
</inputs>

<response_contract>
Every subagent response must be in one of these two formats.

Need user input:

```text
STATUS: NEEDS_INPUT
PHASE: SPEC|PLAN
FEATURE_SLUG: <kebab-case-or-tbd>
COMPLEXITY: quick|standard|high
RISK_LEVEL: low|medium|high
NEXT_ACTION: answer_questions
QUESTIONS:
1) <question>
2) <question>
```

Completed:

```text
STATUS: DONE
PHASE: SPEC|PLAN
FEATURE_SLUG: <kebab-case>
COMPLEXITY: quick|standard|high
RISK_LEVEL: low|medium|high
NEXT_ACTION: <phase-specific action>
OUTPUT_PATH: .planning/ssd/<feature-slug>/<file>.md
SUMMARY:
- <brief point>
- <brief point>
```

If malformed, request one contract-only reformat using the same task_id.
If malformed again, stop with an actionable error.
</response_contract>

<clarification_policy>
Per phase, max clarification rounds with user: 2.

When a phase returns `NEEDS_INPUT` after round 2:
- Resume the same subagent (`task_id`) with instruction to continue using explicit assumptions.
- Ask it to write output and return `STATUS: DONE`.
</clarification_policy>

<process>
## Step 1: Validate input

If `$ARGUMENTS` is empty:
- Ask for short quick-task description and optional slug.
- Stop.

## Step 2: Run quick spec loop

Start spec task:

```text
Task(
  description="SSD quick spec",
  subagent_type="ssd-spec",
  prompt="Create SSD spec in QUICK mode for task: $ARGUMENTS. Use response contract exactly. Ask questions only when critical ambiguity remains. Return complexity and risk triage. Keep scope constrained to quick-safe work (small bug fix, tiny refactor, or very small tweak). For NEXT_ACTION choose proceed_to_plan or handoff_to_ssd_new_feature."
)
```

Loop handling:
- If `STATUS: NEEDS_INPUT`: ask exactly the provided questions, then stop and wait.
- On user answer: resume same `task_id` with `User answers: ...`.
- Enforce max 2 clarification rounds.
- If malformed: one reformat retry; second malformed -> stop with error.

Capture from DONE: `FEATURE_SLUG`, `COMPLEXITY`, `RISK_LEVEL`, `OUTPUT_PATH`.

## Step 3: Quick-scope guardrail

If any of these are true, stop and handoff to full SSD:
- `COMPLEXITY != quick`
- `RISK_LEVEL = high`
- `NEXT_ACTION = handoff_to_ssd_new_feature`

Handoff output:
- explain why task is not quick-safe
- include spec path
- instruct to run `/ssd-new-feature <same request>`

## Step 4: Run quick plan loop

Start plan task:

```text
Task(
  description="SSD quick plan",
  subagent_type="ssd-plan",
  prompt="Create SSD plan in QUICK mode using spec in .planning/ssd/. Use response contract exactly. Plan must be short and reviewable: 1 plan file, 1-3 commit-sized steps, explicit verification for each step. Ask questions only when ambiguity materially changes the plan."
)
```

Loop handling is identical to spec (including malformed-output recovery and max 2 rounds).

Capture from DONE: plan path (`02-plan.md`).

## Step 5: Ask before build (two options)

Ask the user before build with exactly two options:
1) "Stop before build (Recommended)" — keep manual control
2) "Start build now" — run build immediately

If user selects stop:
- report spec and plan paths
- show build command: `@ssd-build`
- remind that build executes `02-plan.md`

If user selects start build:
- run:

```text
Task(
  description="SSD build",
  subagent_type="ssd-build",
  prompt="Implement from .planning/ssd/${FEATURE_SLUG}/02-plan.md (quick mode). Use 00-spec.md and 02-plan.md as required inputs; read 01-deepdive.md only if present. Write 03-build-log.md."
)
```

- then report build-log path and completion status
</process>
