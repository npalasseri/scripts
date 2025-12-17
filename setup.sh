#!/bin/bash

# --- CONFIGURATION ---
VIMRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/vim/vimrc_sample"
ZSHRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/zshrc_personal"

echo "🚀 Starting system setup..."

# 1. Install Homebrew (if not found)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install CLI Tools and Casks
echo "Installing core packages and apps..."
brew install git node fzf
brew install --cask google-chrome intellij-idea-ce visual-studio-code

# 3. Setup Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Install common Zsh plugins (assuming your config uses these)
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo "Cloning Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting 2>/dev/null

# 5. Download and Install Your Custom .zshrc
echo "Applying custom zshrc from GitHub..."
curl -fsSL "$ZSHRC_URL" -o ~/.zshrc

# 6. Setup Vim-Plug
echo "Setting up Vim-Plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 7. Download and Install Your Custom .vimrc
echo "Applying custom vimrc from GitHub..."
curl -fsSL "$VIMRC_URL" -o ~/.vimrc

# 8. Install Vim Plugins
echo "Installing Vim plugins (headless)..."
vim +PlugInstall +qall

# 9. Set up fzf shell integration
if [ -f /opt/homebrew/opt/fzf/install ]; then
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
fi

echo "✅ Setup complete! Restart your terminal or run 'source ~/.zshrc'."
