# Claude Code Apple Devcontainer

A devcontainer setup for running [Claude Code](https://claude.com/claude-code) (and
optionally [Codex CLI](https://github.com/openai/codex)) on macOS using
[Apple's container implementation](https://github.com/apple/container) instead of Docker.

## Background

This project builds on two [Trail of Bits](https://www.trailofbits.com) projects:

- [claude-code-config](https://github.com/trailofbits/claude-code-config)
- [claude-code-devcontainer](https://github.com/trailofbits/claude-code-devcontainer)

Both are designed around Docker and VS Code. This repo adapts them for Apple's
`container` CLI and a Neovim/terminal workflow, with two changes:

- **Separate host and container Claude configs.** claude-code-devcontainer's default
  approach shares `~/.claude` between host and container, which also enables bypass
  permissions in the container. This repo keeps `~/.claude` on the host at safe
  defaults and uses a separate `~/.claude-adevc` for the container's heavier
  customization and bypass permissions.
- **Codex CLI support**, wired up to work with local models served via LM Studio.

## Requirements

- macOS >= 26.3
- [Apple container](https://github.com/apple/container) >= 0.9.0
- An existing `~/.claude` directory (run `claude` on the host at least once first)
- An existing `~/.codex` directory (run `codex` on the host at least once first)

## Setup

1. Clone this repo and `cd` into it.
2. Review [`build-adevc.sh`](build-adevc.sh) before running it.
3. Run it:
   ```
   ./build-adevc.sh
   ```
   This starts the Apple container system, fetches the pinned submodules (see
   below), patches and builds the `adevc` container image, and initializes
   `~/.claude-adevc` and `~/.codex-adevc` from your host configs.
4. Add an alias for the launcher, e.g. in `~/.zshrc`:
   ```
   alias adevc="/path/to/this/repo/adevc.sh"
   ```
5. From any project directory, start a container:
   ```
   cd /path/to/your/project
   adevc
   ```
6. Inside the container, log in once and persist the session:
   ```
   claude
   /login
   /exit
   cp ~/.claude.json ~/.claude/claude.json.adevc
   exit
   ```

## Dependency submodules

`build-adevc.sh` depends on four upstream repos, tracked as git submodules pinned
to known-good commits:

| Submodule | Purpose |
|---|---|
| [claude-code-config](https://github.com/trailofbits/claude-code-config) | CLAUDE.md template, settings, commands, hooks |
| [claude-code-devcontainer](https://github.com/trailofbits/claude-code-devcontainer) | Base Dockerfile, patched by [`Dockerfile.patch`](Dockerfile.patch) |
| [skills](https://github.com/trailofbits/skills) | Trail of Bits skills plugin marketplace |
| [skills-curated](https://github.com/trailofbits/skills-curated) | Curated skills plugin marketplace |

`build-adevc.sh` runs `git submodule update --init` to fetch them at their pinned
commits. If you're bootstrapping submodules into a fresh clone that predates
`.gitmodules`, use [`setup-submodules.sh`](setup-submodules.sh) instead.

To update a pinned commit, `cd` into the submodule, check out the new commit, and
commit the resulting gitlink change in this repo.

## Local models via LM Studio

[`lms-qwen3.sh`](lms-qwen3.sh) loads and serves a local Qwen3 Coder model through
LM Studio. [`zshrc-adevc`](zshrc-adevc) adds a `claude-local` shell function inside
the container that points Claude Code at that LM Studio server instead of
Anthropic's API.

Because localhost DNS forwarding into Apple containers doesn't survive a host
reboot, rerun [`localhost-dns.sh`](localhost-dns.sh) (as root) after rebooting to
restore it.

## Other files

- [`Dockerfile.patch`](Dockerfile.patch) — adds Rust, rsyslog, PlantUML/Graphviz, and
  Codex CLI to the upstream devcontainer image.
- [`known_marketplaces.json`](known_marketplaces.json) — plugin marketplaces
  registered in `~/.claude-adevc`.
- [`codex-config.toml`](codex-config.toml) — seed config copied into
  `~/.codex-adevc/config.toml`.

## Status

This gets the basics of claude-code-devcontainer working under Apple's container
implementation. It doesn't replicate every devcontainer feature.
