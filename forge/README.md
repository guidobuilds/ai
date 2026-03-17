# Forge Agent Team

This package defines a delegate-first Forge architecture:

- one main orchestrator agent (`forge`)
- phase subagents (`forge-explore`, `forge-spec`, `forge-plan`, `forge-build`)
- phase skills (`skills/forge-*/SKILL.md`) as the source of behavior

The orchestrator only coordinates. All technical work is delegated to subagents.

## Install

Run:

```sh
./install.sh
```

Targets:

```sh
./install.sh --target all
./install.sh --target opencode
./install.sh --target claude
```

This installs into OpenCode:

- agents to `~/.config/opencode/agents/`
- commands to `~/.config/opencode/command/`
- workflows to `~/.config/opencode/forge/workflows/`
- skills to `~/.config/opencode/skills/`

For Claude Code it installs:

- skills to `~/.claude/skills/`
- Forge orchestrator block into `~/.claude/CLAUDE.md`

## Commands

- `/forge-new <feature request>`
  - runs `explore -> ask/spec loop -> plan`
  - stops before build
- `/forge-continue [feature-slug]`
  - detects next pending phase
  - continues until next checkpoint (including build when approved)

## Phase flow

`explore -> ask/spec loop -> plan -> build`

### Artifacts

- `.planning/forge/<slug>/00-explore.md`
- `.planning/forge/<slug>/01-spec.md`
- `.planning/forge/<slug>/02-plan.md`
- `.planning/forge/<slug>/03-build-log.md`

## Contract

All subagents must return:

```text
STATUS: success|partial|blocked
PHASE: EXPLORE|SPEC|PLAN|BUILD
FEATURE_SLUG: <kebab-case>
ARTIFACTS:
- <path>
SUMMARY:
- <point>
NEXT_RECOMMENDED: explore|spec|plan|build|none
RISKS:
- <risk or None>
QUESTIONS:
1) <question>
2) <question>
```

`QUESTIONS` is only present when `STATUS: blocked`.

## Layout

- `agents/forge.md`
- `agents/forge-explore.md`
- `agents/forge-spec.md`
- `agents/forge-plan.md`
- `agents/forge-build.md`
- `commands/forge-new.md`
- `commands/forge-continue.md`
- `workflows/forge-new.md`
- `workflows/forge-continue.md`
- `skills/forge-explore/SKILL.md`
- `skills/forge-spec/SKILL.md`
- `skills/forge-plan/SKILL.md`
- `skills/forge-build/SKILL.md`
