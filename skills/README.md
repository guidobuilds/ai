# Skills

This folder tracks third-party skills installed via the `skills` CLI.

## Install / Update

Install the skills listed in `skills-manifest.tsv` to the global scope for
OpenCode and Claude Code:

```sh
./install-skills.sh
```

Behavior:
- Reads the manifest and de-duplicates entries
- If any requested skill is already installed globally, runs `npx skills update`
- Installs each skill with `-g -a opencode -a claude-code -y`

## Manifest format

`skills-manifest.tsv` is a TSV file with a header row:

```
repo	skill
https://github.com/vercel-labs/agent-skills	vercel-react-best-practices
```
