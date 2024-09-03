#!/usr/bin/env bash
#
# Install Scipt Formatting Tools and Configure Vscode for BASH Script Editing
# 
# This script assumes:
#   - that you have already installed VSCode and have the `code`
#     command in your path.
#   - that you are running a Debian based Linux distribution, you will need 
#     to modify the OS package installation commands for your distribution.
#
# Background References:
#   Editor Config Background:
#     https://editorconfig.org/
#   Editor Config VSCode Plugin:
#     https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig
#   Shell Formater:
#     https://github.com/mvdan/sh
#   Shell Formater VSCode Plugin:
#     https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt
#   Shell Linter:
#     https://www.shellcheck.net/
#   Bash IDE VSCode Plugin:
#     https://marketplace.visualstudio.com/items?itemName=mads-hartmann.bash-ide-vscode
#   Bash Debugger VSCode Plugin:
#     https://marketplace.visualstudio.com/items?itemName=rogalmic.bash-debug

set nounset

declare -a os_packages=("shellcheck" "shfmt")
declare -a vscode_extensions=("mkhl.shfmt" "editorconfig.editorconfig" "mads-hartmann.bash-ide-vscode" "rogalmic.bash-debug")

sudo apt-get install -y "${os_packages[@]}"

for extension in "${vscode_extensions[@]}"; do
  code --install-extension "${extension}"
done
