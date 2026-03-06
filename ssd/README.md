# SSD Agents

This folder contains four spec-driven development agents:

- `ssd-spec`
- `ssd-deepdive`
- `ssd-plan`
- `ssd-build`

And two SSD commands:

- `ssd-new-feature` (full cycle)
- `ssd-quick-task` (short cycle)

## Inspiration

This SSD setup is inspired by:

- `gsd-opencode`: https://github.com/rokicool/gsd-opencode
- `get-shit-done`: https://github.com/gsd-build/get-shit-done

## Install

Run:

```sh
./install.sh
```

This installs agents/commands/workflows into OpenCode config directories using native
OpenCode frontmatter.

It also installs SSD orchestration commands:

- OpenCode: `/ssd-new-feature`
- OpenCode: `/ssd-quick-task`

Workflow prompt files are installed to:

- `~/.config/opencode/ssd/workflows/`

## Files

- `agents/ssd-spec.md`
- `agents/ssd-deepdive.md`
- `agents/ssd-plan.md`
- `agents/ssd-build.md`
- `commands/ssd-new-feature.md`
- `commands/ssd-quick-task.md`
- `workflows/ssd-new-feature.md`
- `workflows/ssd-quick-task.md`

## Orchestrator command

Run one command to produce spec, deepdive, and plan (stops before build):

- OpenCode: `/ssd-new-feature <feature description>`

The orchestrator runs each phase in sequence and may pause to ask clarifying
questions when ambiguity is material. It resumes the same phase after your
answers and only proceeds when that phase is complete.

It enforces:
- strict `STATUS` response contracts from subagents
- one malformed-response recovery retry
- max 2 clarification rounds per phase before assumption-based completion
- spec-driven complexity/risk triage to choose deepdive mode (`lite` or `full`)

## Quick command

Run a shorter cycle for very small tasks:

- OpenCode: `/ssd-quick-task <small task description>`

Quick mode runs `spec -> plan` by default and falls back to full flow when the
task is not quick-safe (higher complexity/risk).

Before build, quick mode asks with two options:
- stop before build (recommended)
- start build now

If you stop before build, run the build agent manually:

- OpenCode: `@ssd-build`
