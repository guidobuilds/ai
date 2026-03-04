# Opencode + Context7 Setup

This config uses `${CONTEXT7_API_KEY}` in `opencode.json` so the API key is not hardcoded in versioned files.

## Add the API key to your shell env (macOS)

### zsh (default on modern macOS)
Add this line to `~/.zshrc`:

```sh
export CONTEXT7_API_KEY="your_real_context7_api_key"
```

Then reload:

```sh
source ~/.zshrc
```

### bash
Add this line to `~/.bash_profile` (or `~/.bashrc`):

```sh
export CONTEXT7_API_KEY="your_real_context7_api_key"
```

Then reload:

```sh
source ~/.bash_profile
```

## Verify it is set

```sh
echo $CONTEXT7_API_KEY
```

If it prints your key value, you're ready.

## Restart Opencode

Restart Opencode so it picks up the environment variable.

## Link the versioned config to opencode's config location

Opencode reads its config from `~/.config/opencode/opencode.json`. To point it at the versioned file in this repo, create a symlink:

```sh
ln -sf /Users/guido/guidofigs/opencode/opencode.jsonc ~/.config/opencode/opencode.json
```

Verify the symlink:

```sh
ls -la ~/.config/opencode/opencode.json
# Expected: opencode.json -> /Users/guido/guidofigs/opencode/opencode.jsonc
```

Any edits made by opencode or manually will write directly to the versioned `opencode.jsonc` file.
