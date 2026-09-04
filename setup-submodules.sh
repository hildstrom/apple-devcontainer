#!/bin/bash
# One-time setup: add the pinned dependency repos as git submodules to a
# fresh checkout of this repo (i.e. one where .gitmodules is not yet
# committed). Run once, then commit the result.
set -euo pipefail

add_pinned_submodule() {
  local url="$1"
  local path="$2"
  local commit="$3"

  git submodule add "$url" "$path"
  git -C "$path" checkout "$commit"
  git add "$path"
}

add_pinned_submodule \
  https://github.com/trailofbits/claude-code-config.git \
  claude-code-config \
  7db11a2803d304d294ebace78c0687e701385947

add_pinned_submodule \
  https://github.com/trailofbits/claude-code-devcontainer.git \
  claude-code-devcontainer \
  48df2ad80d33216d04354088704591fb8ceec6b0

add_pinned_submodule \
  https://github.com/trailofbits/skills.git \
  skills \
  1efb11a08f9865f4e33392133328e5f1404db05b

add_pinned_submodule \
  https://github.com/trailofbits/skills-curated.git \
  skills-curated \
  022fa0948818c9f2f738a428f4546cc65c427767

git add .gitmodules

echo
echo "Submodules staged at their pinned commits. Review with 'git status' and commit."
echo
