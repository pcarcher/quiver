#!/usr/bin/env bash

# --- Global Configuration ---
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CONFIGS_DIR="$DOTFILES_DIR/configs"
export MODULES_DIR="$DOTFILES_DIR/modules"

# --- Load Utilities ---
source "$DOTFILES_DIR/lib/utils.sh"

# --- OS and Package Manager Detection ---
detect_os

# --- Ensure GUM is installed (for pro menu) ---
ensure_gum

# --- Script Start ---
print_banner "QUIVER: Archer's Dotfiles Manager"

# 0. Select utilities to install
log_section "Step 1: Utilities"
SELECTED_UTILS=$(select_utilities)
if [ -n "$SELECTED_UTILS" ]; then
  install_selected_utilities "$SELECTED_UTILS"
else
  log_warn "No utilities selected. Continuing..."
fi

# 1. Scan available modules in modules/ folder
MODULE_NAMES=($(ls "$MODULES_DIR"/*.sh))

log_section "Step 2: Modules"

if [ -n "$AUTO_SELECT" ]; then
  SELECTED="$AUTO_SELECT"
else
  MODULE_BASES=("${MODULE_NAMES[@]##*/}")
  log_info "Use [SPACE] to select and [ENTER] to confirm"
  SELECTED=$(gum choose --no-limit --cursor-prefix "○ " --selected-prefix "◉ " --unselected-prefix "○ " "${MODULE_BASES[@]}")
fi

if [ -z "$SELECTED" ]; then
  log_warn "Nothing selected. Exiting..."
  exit 0
fi

for item in $SELECTED; do
  log_section "Installing: $item"
  source "$MODULES_DIR/$item.sh"

  if focus_install; then
    log_success "$item completed successfully."
  else
    log_error "Error installing $item."
  fi
done

if gum confirm "Add zsh configuration to .zshrc?"; then
  log_info "Adding zsh configuration..."
  ln -sfn "$CONFIGS_DIR/zsh/config.zsh" "$HOME/.zsh_aliases"
  grep -qxF '[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases || true' ~/.zshrc ||
    echo '[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases || true' >>~/.zshrc
fi

print_banner "All done, Archer! Enjoy your setup."
