#!/bin/bash

container run -it --rm \
--mount "source=.,target=/workspace" \
--mount "source=~/.claude-adevc,target=/home/vscode/.claude" \
--mount "source=~/.codex-adevc,target=/home/vscode/.codex" \
--cpus 8 \
--memory 8G \
adevc zsh

