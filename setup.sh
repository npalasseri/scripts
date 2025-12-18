#!/bin/bash

# --- CONFIGURATION ---
VIMRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/vim/vimrc_sample"
ZSHRC_URL="https://raw.githubusercontent.com/npalasseri/scripts/master/zshrc_personal"

echo "🚀 Starting system setup..."

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install CLI Tools and Apps
echo "Installing core packages and apps..."
brew install git node fzf
brew install --cask google-chrome intellij-idea-ce visual-studio-code

# 3. Setup Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Clone Zsh Plugins (Commonly used in personal zshrcs)
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting 2>/dev/null

# 5. Download your .zshrc
curl -fsSL "$ZSHRC_URL" -o ~/.zshrc

# 6. Setup Pathogen (Required by your .vimrc)
echo "Setting up Pathogen..."
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# 7. Download your .vimrc
echo "Applying your .vimrc..."
curl -fsSL "$VIMRC_URL" -o ~/.vimrc

# 8. Note on Vim Plugins
echo "--------------------------------------------------------"
echo "NOTE: Pathogen requires plugins to be cloned manually into:"
echo "~/.vim/bundle/"
echo "Your .vimrc is now active and the error should be gone."
echo "--------------------------------------------------------"

# 9. Set up fzf shell integration
if [ -f /opt/homebrew/opt/fzf/install ]; then
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
fi

echo "✅ Setup complete!"
