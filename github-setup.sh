#!/bin/bash

# --- CONFIGURATION ---
# Personal Account
P_EMAIL="personal@email.com"
P_KEY="$HOME/.ssh/id_ed25519_personal"

# Work Account
W_EMAIL="work@company.com"
W_KEY="$HOME/.ssh/id_ed25519_work"

echo "🔑 Starting Multi-Account SSH Setup..."

# 1. Generate Personal Key
if [ ! -f "$P_KEY" ]; then
    echo "Generating Personal key..."
    ssh-keygen -t ed25519 -C "$P_EMAIL" -f "$P_KEY" -N ""
fi

# 2. Generate Work Key
if [ ! -f "$W_KEY" ]; then
    echo "Generating Work key..."
    ssh-keygen -t ed25519 -C "$W_EMAIL" -f "$W_KEY" -N ""
fi

# 3. Create/Overwrite SSH Config
# This routes the traffic to the correct key using "Aliases"
echo "Configuring ~/.ssh/config..."
cat <<EOT > ~/.ssh/config
# Personal GitHub Account
Host github.com-personal
  HostName github.com
  User git
  IdentityFile $P_KEY
  AddKeysToAgent yes
  UseKeychain yes

# Work GitHub Account
Host github.com-work
  HostName github.com
  User git
  IdentityFile $W_KEY
  AddKeysToAgent yes
  UseKeychain yes
EOT

# 4. Add keys to Apple Keychain
ssh-add --apple-use-keychain "$P_KEY"
ssh-add --apple-use-keychain "$W_KEY"

echo "-------------------------------------------------------"
echo "✅ SSH KEYS GENERATED"
echo "-------------------------------------------------------"
echo "Personal Public Key (Copied to clipboard):"
cat "$P_KEY.pub"
cat "$P_KEY.pub" | pbcopy
echo "-> Paste this into your PERSONAL GitHub settings."
echo ""
echo "Press Enter once you have added the Personal key to move to the Work key..."
read

echo "Work Public Key (Copied to clipboard):"
cat "$W_KEY.pub" | pbcopy
cat "$W_KEY.pub"
echo "-> Paste this into your WORK GitHub settings."
echo "-------------------------------------------------------"
