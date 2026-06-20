#!/usr/bin/env bash

# --- Modulo Nerd-Fonts para Quiver ---

focus_install() {
  log_info "Preparing to install Nerd Fonts..."

  # Dependencies
  local dependencies=(fontconfig unzip)
  # Note: fc-list and fc-cache come in the fontconfig package on most distros
  
  for dep in unzip fontconfig; do
    if ! command -v "$dep" &>/dev/null && [[ "$dep" != "fontconfig" ]]; then
        log_warn "Installing missing dependency: $dep"
        $PKM "$dep"
    fi
  done

  # Ask for the font name using GUM
  log_info "Examples: Hack, FiraCode, JetBrainsMono, Iosevka"
  local font_name
  font_name=$(gum input --placeholder "Type the Nerd Font name (e.g., Hack)...")

  if [ -z "$font_name" ]; then
    log_warn "No font name provided. Cancelling."
    return 1
  fi

  # Check if it already exists
  local similar
  similar=$(fc-list : family | sort | uniq | grep -i "$font_name" 2>/dev/null)

  if [ -n "$similar" ]; then
    log_warn "Similar fonts already installed found:"
    echo "$similar"
    if ! gum confirm "Do you want to continue installing '$font_name'?"; then
      log_info "Installation cancelled."
      return 0
    fi
  fi

  # Download and installation process
  local repo_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  log_info "Downloading $font_name..."
  if ! gum spin --spinner dot --title "Downloading from GitHub" -- curl -L -o "$tmp_dir/font.zip" "$repo_url"; then
    log_error "Could not download the font. Check the name (it's case-sensitive)."
    rm -rf "$tmp_dir"
    return 1
  fi

  log_info "Extracting files..."
  unzip -q "$tmp_dir/font.zip" -d "$tmp_dir"

  local user_fonts_dir
  if [[ "$OS_TYPE" == "mac" ]]; then
    user_fonts_dir="$HOME/Library/Fonts"
  else
    user_fonts_dir="$HOME/.local/share/fonts"
  fi

  mkdir -p "$user_fonts_dir"

  log_info "Installing to $user_fonts_dir..."
  # Search and move font files
  find "$tmp_dir" -name "*.[o|t]tf" -exec mv {} "$user_fonts_dir/" \; 2>/dev/null

  log_info "Updating font cache..."
  fc-cache -f &>/dev/null

  rm -rf "$tmp_dir"
  
  log_success "Nerd Font '$font_name' installed successfully."
  return 0
}
