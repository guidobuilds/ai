<purpose>
Orchestrate SSD for non-trivial work:
1) spec
2) deepdive
3) plan
4) stop before build

Performance goals:
- Keep orchestrator lean
- Ask only high-impact questions
- Enforce strict response contract for reliable parsing
</purpose>

<inputs>
- Feature request: `$ARGUMENTS`
</inputs>

<response_contract>
Every subagent response must be in one of these two formats.

Need user input:

```text
STATUS: NEEDS_INPUT
PHASE: SPEC|DEEPDIVE|PLAN
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
PHASE: SPEC|DEEPDIVE|PLAN
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
- Ask it to write its output and return `STATUS: DONE`.
- Include assumptions in summary.
</clarification_policy>

<process>
## Step 1: Validate input

If `$ARGUMENTS` is empty:
- Ask for short feature description and optional slug.
- Stop.

## Step 2: Run spec loop

Start spec task:

```text
Task(
  description="SSD spec",
  subagent_type="ssd-spec",
  prompt="Create SSD spec for feature request: $ARGUMENTS. Use response contract exactly. Ask questions only when critical ambiguity remains. Return complexity and risk triage. For NEXT_ACTION, choose proceed_to_deepdive_lite or proceed_to_deepdive_full."
)
```

Loop handling:
- If `STATUS: NEEDS_INPUT`: ask exactly the provided questions, then stop and wait.
- On user answer: resume same `task_id` with `User answers: ...`.
- Enforce max 2 clarification rounds.
- If malformed: one reformat retry; second malformed -> stop with error.

Capture from DONE: `FEATURE_SLUG`, `COMPLEXITY`, `RISK_LEVEL`, `OUTPUT_PATH` (00-spec path), `NEXT_ACTION`.

## Step 3: Select deepdive mode

Use spec triage:
- If `NEXT_ACTION = proceed_to_deepdive_lite`, run deepdive in lite mode.
- Else run deepdive in full mode.

Safety override:
- If `RISK_LEVEL = high`, force full mode.

## Step 4: Run deepdive loop

Start deepdive task:

```text
Task(
  description="SSD deepdive",
  subagent_type="ssd-deepdive",
  prompt="Run SSD deepdive from .planning/ssd/. Mode: ${DEEPDIVE_MODE}. Use response contract exactly. Ask questions only when unresolved ambiguity affects risk, scope, architecture, or rollout. Return NEXT_ACTION=proceed_to_plan when complete."
)
```

Loop handling is identical to spec (including malformed-output recovery and max 2 rounds).

Capture from DONE: deepdive path (`01-deepdive.md`).

## Step 5: Run plan loop

Start plan task:

```text
Task(
  description="SSD plan",
  subagent_type="ssd-plan",
  prompt="Produce commit-sized SSD plan from spec and deepdive in .planning/ssd/. Use response contract exactly. Ask questions only when ambiguity materially changes commit boundaries, sequencing, risk mitigation, or verification."
)
```

Loop handling is identical to spec/deepdive.

Capture from DONE: plan path (`02-plan.md`).

## Step 6: Stop before build

Report:
- Path to `00-spec.md`
- Path to `01-deepdive.md`
- Path to `02-plan.md`
- Build start command: `@ssd-build`
- Reminder: build is manual and executes `02-plan.md`
</process>
