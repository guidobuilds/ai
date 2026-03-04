---
opencode: {"description":"Run SSD spec -> deepdive -> plan (stops before build)","temperature":0.2,"tools":{"task":true,"read":true,"write":true,"edit":true,"bash":true,"glob":true,"grep":true}}
claude: {"name":"ssd:new-feature","description":"Run SSD spec -> deepdive -> plan (stops before build)","tools":["Read","Write","Edit","Bash","Grep","Glob","Task"],"model":"inherit"}
---

# SSD Orchestrator: Spec -> Deepdive -> Plan

If `$ARGUMENTS` is empty, ask the user for a short feature description and (optionally) a preferred slug, then stop.

## Inputs

- Feature request: `$ARGUMENTS`

## Flow

1) Run `ssd-spec` to create the spec.
2) Run `ssd-deepdive` to map risks and touchpoints.
3) Run `ssd-plan` to produce the commit-sized plan.
4) Stop and report next steps (do not run build).

## Execution

Use Task for each subagent in order, and wait for each to complete before proceeding.

Task 1:

```
Task(
  description="SSD spec",
  subagent_type="ssd-spec",
  prompt="Create the SSD spec for the following feature request. Ask any required questions. Feature request: $ARGUMENTS"
)
```

Task 2:

```
Task(
  description="SSD deepdive",
  subagent_type="ssd-deepdive",
  prompt="Run the SSD deepdive based on the spec created in .planning/ssd/. If questions remain, ask them."
)
```

Task 3:

```
Task(
  description="SSD plan",
  subagent_type="ssd-plan",
  prompt="Produce the SSD plan based on the spec and deepdive in .planning/ssd/."
)
```

## Stop Condition

After Task 3, report:
- Paths to `00-spec.md`, `01-deepdive.md`, `02-plan.md`
- How to start build: `@ssd-build` or `/ssd-build` depending on runtime
- Reminder that build is manual and will execute the plan
