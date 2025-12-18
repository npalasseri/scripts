#!/bin/bash

# --- CONFIGURATION ---
ZSHRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/zshrc_personal"
VIMRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/vim/vimrc_sample"

echo "🚀 Starting Full System Setup..."

# 1. Homebrew & App Installation
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Installing CLI tools and Apps..."
brew install git node fzf vim
brew install --cask google-chrome intellij-idea-ce visual-studio-code

# 2. Oh My Zsh & External Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_CUSTOM"

echo "Cloning Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/zsh-autosuggestions" 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/zsh-syntax-highlighting" 2>/dev/null
git clone https://github.com/joshskidmore/zsh-fzf-history-search "${ZSH_CUSTOM}/zsh-fzf-history-search" 2>/dev/null

# 3. SCD (Smart Change Directory) Setup
echo "Setting up SCD..."
git clone https://github.com/pavoljuhas/smart-change-directory.git "$HOME/.smart-change-directory" 2>/dev/null
mkdir -p "${ZSH_CUSTOM}/scd"
echo 'source "$HOME/.smart-change-directory/shellrcfiles/zshrc_scd"' > "${ZSH_CUSTOM}/scd/scd.plugin.zsh"

# 4. Vim Setup (Pathogen + Theme)
echo "Configuring Vim..."
mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/pack/themes/opt
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install Srcery Theme
echo "Installing Srcery Theme..."
git clone https://github.com/srcery-colors/srcery-vim ~/.vim/pack/themes/opt/srcery-vim 2>/dev/null

# Download and Update .vimrc
curl -fsSL "$VIMRC_URL" -o ~/.vimrc
cat <<EOT >> ~/.vimrc

" Added by setup script
packadd! srcery-vim
colorscheme srcery
EOT

# 5. Zsh Configuration
echo "Applying .zshrc..."
curl -fsSL "$ZSHRC_URL" -o ~/.zshrc

# Ensure Homebrew Vim is the default to fix UltiSnips py3 error
if ! grep -q "opt/homebrew/bin" ~/.zshrc; then
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
fi

echo "-------------------------------------------------------"
echo "✅ SETUP COMPLETE!"
echo "1. Run: source ~/.zshrc"
echo "2. Open Vim and verify the Srcery theme and UltiSnips."
echo "-------------------------------------------------------"
