#!/bin/bash

# --- CONFIGURATION ---
# Format: "Alias : Email : Folder_Path : Full_Name"
ACCOUNTS=(
    "personal:personal@email.com:~/dev/personal:John Doe"
    "work:j.doe@company.com:~/dev/work:John Doe Work"
)

# Add names here to reset (e.g., OVERWRITE_LIST="work")
OVERWRITE_LIST=""

SSH_CONFIG_FILE="$HOME/.ssh/config"
GLOBAL_GITCONFIG="$HOME/.gitconfig"

echo "🚀 Starting Full Git & SSH Synchronization..."

# Ensure base directories exist
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG_FILE"
touch "$GLOBAL_GITCONFIG"

for entry in "${ACCOUNTS[@]}"; do
    IFS=":" read -r NAME EMAIL FOLDER FULLNAME <<< "$entry"
    
    FOLDER_FULL=$(eval echo "$FOLDER")
    mkdir -p "$FOLDER_FULL"

    KEY_PATH="$HOME/.ssh/id_ed25519_$NAME"
    HOST_ALIAS="github.com-$NAME"
    GITCONFIG_SUB="$HOME/.gitconfig-$NAME"

    # 1. SSH KEY MANAGEMENT
    SHOULD_OVERWRITE=false
    [[ $OVERWRITE_LIST =~ (^|[[:space:]])"$NAME"($|[[:space:]]) ]] && SHOULD_OVERWRITE=true

    if [ "$SHOULD_OVERWRITE" = true ] || [ ! -f "$KEY_PATH" ]; then
        rm -f "$KEY_PATH" "$KEY_PATH.pub"
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
        NEW_KEY_CREATED=true
    fi

    # 2. SSH CONFIG MANAGEMENT
    if ! grep -q "Host $HOST_ALIAS" "$SSH_CONFIG_FILE" || [ "$SHOULD_OVERWRITE" = true ]; then
        sed -i '' "/# $NAME GitHub Account/,/UseKeychain yes/d" "$SSH_CONFIG_FILE" 2>/dev/null
        cat <<EOF >> "$SSH_CONFIG_FILE"

# $NAME GitHub Account
Host $HOST_ALIAS
  HostName github.com
  User git
  IdentityFile $KEY_PATH
  AddKeysToAgent yes
  UseKeychain yes
EOF
    fi

    # 3. AUTOMATED GIT IDENTITY
    cat <<EOF > "$GITCONFIG_SUB"
[user]
    name = $FULLNAME
    email = $EMAIL
[core]
    sshCommand = "ssh -i $KEY_PATH"
EOF

    if ! grep -q "path = $GITCONFIG_SUB" "$GLOBAL_GITCONFIG"; then
        cat <<EOF >> "$GLOBAL_GITCONFIG"

[includeIf "gitdir:$FOLDER_FULL/"]
    path = $GITCONFIG_SUB
EOF
    fi

    ssh-add --apple-use-keychain "$KEY_PATH" 2>/dev/null
done

# --- 4. THE DOCTOR COMMAND ---
echo ""
echo "🩺 RUNNING DIAGNOSTICS FOR CURRENT DIRECTORY..."
CURRENT_DIR=$(pwd)
MATCH_FOUND=false

echo "Current Path: $CURRENT_DIR"

for entry in "${ACCOUNTS[@]}"; do
    IFS=":" read -r NAME EMAIL FOLDER FULLNAME <<< "$entry"
    FOLDER_FULL=$(eval echo "$FOLDER")

    # Check if current directory is inside the configured account folder
    if [[ "$CURRENT_DIR" == "$FOLDER_FULL"* ]]; then
        MATCH_FOUND=true
        echo "✅ Context Match: You are in the [$NAME] zone."
        
        # Test Git Identity
        ACTUAL_EMAIL=$(git config user.email)
        if [ "$ACTUAL_EMAIL" == "$EMAIL" ]; then
            echo "  ✅ Git Email: $ACTUAL_EMAIL (Correct)"
        else
            echo "  ❌ Git Email: $ACTUAL_EMAIL (Expected $EMAIL)"
        fi

        # Test SSH Connection
        echo "  📡 Testing SSH Connection to GitHub ($NAME)..."
        ssh -T "git@github.com-$NAME" -o "ConnectTimeout=5" 2>&1 | grep -q "successfully authenticated"
        if [ $? -eq 0 ]; then
            echo "  ✅ SSH Auth: Success"
        else
            echo "  ❌ SSH Auth: Failed (Check if key is added to GitHub settings)"
        fi
    fi
done

if [ "$MATCH_FOUND" = false ]; then
    echo "⚠️  No specific account match found for this folder."
    echo "   Git will use your global default identity."
fi

# --- 5. FINAL STATUS REPORT ---
echo ""
echo "======================================================="
echo "📊 SYSTEM STATUS REPORT"
echo "======================================================="
echo "🔑 Active SSH Identities in Agent:"
ssh-add -l | awk '{print "  active -> " $3}'
echo "======================================================="
echo "✨ Setup & Diagnostics Complete."
