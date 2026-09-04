#!/bin/bash

#lms get Qwen3-Coder-Next@MLX-4bit -y

lms load qwen/qwen3-coder-next --context-length 65536 --gpu max -y
lms server start

