#!/bin/bash
# git-multiple-identities: One global Git identity + multiple path-specific identities.

set -e

echo "=============================================="
echo "  Git Multiple Identities - Setup"
echo "=============================================="
echo ""

# --- Global default identity ---
echo "1) GLOBAL DEFAULT (used for repos that don't match any path below)"
read -p "   Git user name: " GLOBAL_NAME
read -p "   Git email: " GLOBAL_EMAIL
echo ""

# --- Path-specific identities ---
declare -a LABELS
declare -a PATHS
declare -a NAMES
declare -a EMAILS

while true; do
  read -p "Add a path-specific identity? (y/n): " ADD
  case "$ADD" in
    [yY]|[yY][eE][sS])
      read -p "   Label (e.g. office, client-a): " LABEL
      read -p "   Folder path (e.g. ~/Desktop/paytm or ~/work): " FPATH
      read -p "   Git user name: " PNAME
      read -p "   Git email: " PEMAIL
      LABELS+=("$LABEL")
      PATHS+=("$FPATH")
      NAMES+=("$PNAME")
      EMAILS+=("$PEMAIL")
      echo "   Added identity '$LABEL' for path $FPATH"
      echo ""
      ;;
    *)
      break
      ;;
  esac
done

if [ ${#LABELS[@]} -eq 0 ]; then
  echo "No path-specific identities. Only global config will be written."
  echo ""
fi

# --- Path normalization ---
normalize_path() {
  local p="$1"
  p="${p/#\~/$HOME}"
  [[ "$p" != */ ]] && p="$p/"
  echo "$p"
}

gitdir_for_include() {
  local p="$1"
  if [[ "$p" == "$HOME"/* ]]; then
    echo "~/${p#$HOME/}"
  else
    echo "$p"
  fi
}

# --- Backup ---
GITCONFIG_MAIN="$HOME/.gitconfig"
if [ -f "$GITCONFIG_MAIN" ]; then
  BACKUP="$HOME/.gitconfig.backup.$(date +%Y%m%d%H%M%S)"
  cp "$GITCONFIG_MAIN" "$BACKUP"
  echo "Backed up existing config to: $BACKUP"
  echo ""
fi

# Preserve [credential] from existing config
CREDENTIAL_BLOCK=""
if [ -f "$GITCONFIG_MAIN" ] && grep -q '^\[credential\]' "$GITCONFIG_MAIN" 2>/dev/null; then
  CREDENTIAL_BLOCK=$(sed -n '/^\[credential\]/,/^\[/p' "$GITCONFIG_MAIN" | sed '/^\[/d' | sed 's/^/\t/')
  CREDENTIAL_BLOCK="[credential]
$CREDENTIAL_BLOCK"
fi

# --- Write per-identity config files ---
for i in "${!LABELS[@]}"; do
  L="${LABELS[$i]}"
  CF="$HOME/.gitconfig-$L"
  cat > "$CF" << EOF
[user]
	name = ${NAMES[$i]}
	email = ${EMAILS[$i]}
EOF
  echo "Wrote: $CF"
done

# --- Build main config ---
MAIN="[user]
	name = $GLOBAL_NAME
	email = $GLOBAL_EMAIL
"

for i in "${!LABELS[@]}"; do
  L="${LABELS[$i]}"
  P=$(normalize_path "${PATHS[$i]}")
  GITDIR=$(gitdir_for_include "$P")
  MAIN="$MAIN

[includeIf \"gitdir:$GITDIR\"]
	path = $HOME/.gitconfig-$L"
done

if [ -n "$CREDENTIAL_BLOCK" ]; then
  MAIN="$MAIN

$CREDENTIAL_BLOCK"
fi

echo "$MAIN" > "$GITCONFIG_MAIN"
echo "Wrote: $GITCONFIG_MAIN"
echo ""

# --- Summary ---
echo "=============================================="
echo "  Done"
echo "=============================================="
echo "  GLOBAL (default): $GLOBAL_NAME <$GLOBAL_EMAIL>"
for i in "${!LABELS[@]}"; do
  P=$(normalize_path "${PATHS[$i]}")
  echo "  ${LABELS[$i]}: ${NAMES[$i]} <${EMAILS[$i]}>  →  $P"
done
echo ""
echo "  Verify: run 'git config user.name && git config user.email' inside a repo in each path."
echo "=============================================="
