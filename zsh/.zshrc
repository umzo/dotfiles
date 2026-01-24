# ============================================================
#   Environment Variables / PATH
# ============================================================

# Homebrew grep
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"

# mise
eval "$(mise activate zsh)"

# claude
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR=nvim

# pkg-config (for phpenv etc.)
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig:/usr/local/opt/libzip/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/bzip2/lib/pkgconfig:/usr/local/opt/oniguruma/lib/pkgconfig"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# ============================================================
#   History Settings
# ============================================================

HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups   # 重複を表示しない
setopt hist_save_no_dups      # 重複保存時は古い方を削除
setopt inc_append_history     # 他のzshと履歴を共有
setopt share_history

alias history='fc -lt "%F %T" 1'

# ============================================================
#   Completions (early init for tools that need compdef)
# ============================================================
autoload -Uz compinit && compinit

# ============================================================
#   Aliases
# ============================================================

alias vi='nvim'
alias c='cursor'
alias godot='/Applications/Godot.app/Contents/MacOS/Godot'

# colordiff
if [[ -x $(which colordiff) ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

# eza (ls replacement)
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  alias ll='eza -l --git --icons'
  alias la='eza -la --git --icons'
  alias lt='eza --tree --level=2 --icons'
fi

# bat (cat replacement)
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'  # with pager
fi

# yazi
function y() {
  export YAZI_START_DIR="$PWD"
  yazi "$@"
}

# zoxide
eval "$(zoxide init zsh)"

# direnv
eval "$(direnv hook zsh)"

# wtp
eval "$(wtp shell-init zsh)"

# ============================================================
#   iTerm2 Functions
# ============================================================

# tn: タブ名を設定（タブ内の全ペインに適用）
tn() {
  if [[ -z "$1" ]]; then
    echo "Usage: tn <tab_name>"
    return 1
  fi
  osascript -e "tell application \"iTerm2\" to tell current tab of current window
    repeat with s in sessions
      tell s to set name to \"$1\"
    end repeat
  end tell"
}

# tn-s: 現在のタブ名を取得
tn-s() {
  osascript -e 'tell application "iTerm2" to tell current session of current tab of current window to get name' | sed 's/ ([^)]*)$//'
}

# ============================================================
#   Safety Functions
# ============================================================

# terraform: 危険なコマンドを無効化
terraform() {
  case $1 in
    apply|destroy|import|state)
      echo "⚠️  terraform $1 is disabled for safety. Please use Terraform Cloud."
      ;;
    taint|untaint)
      echo "⚠️  terraform $1 is disabled for safety. Please use Terraform Cloud."
      ;;
    *)
      command terraform "$@"
      ;;
  esac
}

# git: force push時に確認
function git() {
  if [[ $1 == "push" && $2 == "-f" ]]; then
    echo "本当に強制プッシュ（git push -f）を実行しますか？ [y/N]"
    read answer
    if [[ $answer != "y" ]]; then
      echo "強制プッシュはキャンセルされました。"
      return 1
    fi
  fi
  command git "$@"
}

# 確認プロンプト (必要に応じてaliasで使用)
confirm_command() {
  echo "実行するには 'y' を、キャンセルするには 'n' を入力してください: $*"
  read -q "response?"
  echo
  if [[ $response =~ ^[Yy]$ ]]; then
    "$@"
  else
    echo "キャンセルされました"
  fi
}
# alias rm="confirm_command rm"

# ============================================================
#   Sheldon Plugin Manager
# ============================================================

eval "$(sheldon source)"

# zsh-autosuggestions: Ctrl+F で単語単位の部分補完（空白区切り）
# NOTE: vi-forward-blank-word等のzsh組み込みウィジェットはzsh-autosuggestionsに
# フックされており、カスタムウィジェット内から呼び出すと複数回トリガーされて
# 文字が重複する問題が発生する。そのため、BUFFER/POSTDISPLAY/CURSORを直接操作する。
_autosuggest_partial_word() {
  # サジェストがなければ何もしない
  [[ -z "$POSTDISPLAY" ]] && return

  # サジェストをバッファに追加
  local suggestion="$POSTDISPLAY"
  BUFFER="$BUFFER$suggestion"
  POSTDISPLAY=""

  # 空白をスキップ
  while [[ $CURSOR -lt ${#BUFFER} && "${BUFFER:$CURSOR:1}" == " " ]]; do
    ((CURSOR++))
  done

  # /で始まる場合は/を含めて進む
  if [[ "${BUFFER:$CURSOR:1}" == "/" ]]; then
    ((CURSOR++))
  fi

  # 次の区切り（空白または/）まで進む
  while [[ $CURSOR -lt ${#BUFFER} && "${BUFFER:$CURSOR:1}" != " " && "${BUFFER:$CURSOR:1}" != "/" ]]; do
    ((CURSOR++))
  done

  # カーソル以降を再びサジェストに戻す
  if [[ $CURSOR -lt ${#BUFFER} ]]; then
    POSTDISPLAY="${BUFFER:$CURSOR}"
    BUFFER="${BUFFER:0:$CURSOR}"
  fi

  # シンタックスハイライトを再描画
  zle redisplay
}
zle -N _autosuggest_partial_word
bindkey '^F' _autosuggest_partial_word

# ============================================================
#   Completions
# ============================================================

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# ============================================================
#   Starship Prompt
# ============================================================
eval "$(starship init zsh)"

# ============================================================
#   Local Settings (tokens, secrets, etc.)
# ============================================================

# GITHUB_TOKEN等の秘密情報は ~/.zshrc.local に記載して読み込む
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
