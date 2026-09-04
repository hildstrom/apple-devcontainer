#!/bin/bash

# start apple container system
container system start
if [ $? -ne 0 ]; then
  echo "error: could not start container system"
  exit 1
fi

# clone/pull claude-code-config
if [ -d claude-code-config ]; then
  git -C claude-code-config restore .
  git -C claude-code-config checkout main
  git -C claude-code-config pull
else
  git clone https://github.com/trailofbits/claude-code-config.git
fi
git -C claude-code-config checkout 7db11a2803d304d294ebace78c0687e701385947

# clone/pull claude-code-devcontainer
if [ -d claude-code-devcontainer ]; then
  git -C claude-code-devcontainer restore .
  git -C claude-code-devcontainer checkout main
  git -C claude-code-devcontainer pull
else
  git clone https://github.com/trailofbits/claude-code-devcontainer.git
fi
git -C claude-code-devcontainer checkout 48df2ad80d33216d04354088704591fb8ceec6b0

# clone/pull skills
if [ -d skills ]; then
  git -C skills restore .
  git -C skills checkout main
  git -C skills pull
else
  git clone https://github.com/trailofbits/skills.git
fi
git -C skills checkout 1efb11a08f9865f4e33392133328e5f1404db05b

# clone/pull skills-curated
if [ -d skills-curated ]; then
  git -C skills-curated restore .
  git -C skills-curated checkout main
  git -C skills-curated pull
else
  git clone https://github.com/trailofbits/skills-curated.git
fi
git -C skills-curated checkout 022fa0948818c9f2f738a428f4546cc65c427767

# patch claude-code-devcontainer and copy necessary files
patch claude-code-devcontainer/Dockerfile Dockerfile.patch
cp zshrc-adevc claude-code-devcontainer/

# set up ~/.claude-adevc from host ~/.claude
if [ ! -d ~/.claude ]; then
  echo "error: claude must be run on the host to initialize ~/.claude as a template"
  exit 1
fi
if [ ! -d ~/.claude-adevc ]; then
  cp -a ~/.claude ~/.claude-adevc
  cp claude-code-config/claude-md-template.md ~/.claude-adevc/CLAUDE.md
  cp claude-code-config/scripts/statusline.sh ~/.claude-adevc/statusline.sh
  cp claude-code-config/settings.json ~/.claude-adevc/settings.json
  mkdir ~/.claude-adevc/plugins/marketplaces/tob-skills
  cp -a skills/plugins/* ~/.claude-adevc/plugins/marketplaces/tob-skills/
  mkdir ~/.claude-adevc/plugins/marketplaces/tob-skills-curated
  cp -a skills-curated/plugins/* ~/.claude-adevc/plugins/marketplaces/tob-skills-curated/
  cp known_marketplaces.json ~/.claude-adevc/plugins/known_marketplaces.json
  mkdir ~/.claude-adevc/commands
  cp claude-code-config/commands/* ~/.claude-adevc/commands/
  mkdir ~/.claude-adevc/hooks
  cp claude-code-config/hooks/* ~/.claude-adevc/hooks/
  echo "Directory ~/.claude-adevc initialized"
fi
if [ ! -f ~/.claude-adevc/claude.json.adevc ]; then
  cp ~/.claude.json ~/.claude-adevc/claude.json.adevc
  echo
  echo "You may need to /login in claude in the dev container and then"
  echo "cp ~/.claude.json ~/.claude/claude.json.adevc in the container"
  echo "to persist it. This is a result of missing file bind mounts in"
  echo "the mac container implementation."
  echo
fi

# set up ~/.codex-adevc from host ~/.codex
if [ ! -d ~/.codex ]; then
  echo "error: codex must be run on the host to initialize ~/.codex as a template"
  exit 1
fi
if [ ! -d ~/.codex-adevc ]; then
  cp -a ~/.codex ~/.codex-adevc
  cp codex-config.toml ~/.codex-adevc/config.toml
  echo "Directory ~/.codex-adevc initialized"
fi

# allow containers to access localhost services like lm studio
container system dns list | grep -q host.container.internal
if [ $? -ne 0 ]; then
  echo "Setting up localhost container system dns via sudo"
  sudo container system dns create host.container.internal --localhost 203.0.113.113
fi

# build the container image
container build -t adevc -c 4 -m 4G claude-code-devcontainer

# note about alias for adevc.sh
echo
echo "You may want to alias adevc=\"bash $PWD/adevc.sh\" in your ~/.zshrc for ease of use"
echo

