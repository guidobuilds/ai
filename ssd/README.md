# SSD Agents

This folder contains four spec-driven development agents:

- `ssd-spec`
- `ssd-deepdive`
- `ssd-plan`
- `ssd-build`

## Install

Run:

```sh
./install.sh
```

This installs the agents into OpenCode and Claude Code agent directories by copying
rendered frontmatter for each runtime.

It also installs the SSD orchestration command:

- Claude Code: `/ssd:new-feature`
- OpenCode: `/ssd-new-feature`

## Files

- `agents/ssd-spec.md`
- `agents/ssd-deepdive.md`
- `agents/ssd-plan.md`
- `agents/ssd-build.md`

## Orchestrator command

Run one command to produce spec, deepdive, and plan (stops before build):

- Claude Code: `/ssd:new-feature <feature description>`
- OpenCode: `/ssd-new-feature <feature description>`

Then run the build agent manually:

- Claude Code: `@ssd-build`
- OpenCode: `@ssd-build`
