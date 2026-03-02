# ============================================================
#   Environment Variables / PATH
# ============================================================

# Homebrew (Apple Silicon: パス固定のためサブプロセスを避けて静的エクスポート)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# mise
eval "$(mise activate zsh)"

# claude
export PATH="$HOME/.local/bin:$PATH"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"

# lazygit
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Default editor
export EDITOR=nvim

# pkg-config (for phpenv etc.)
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig:/usr/local/opt/libzip/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/bzip2/lib/pkgconfig:/usr/local/opt/oniguruma/lib/pkgconfig"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# git: リモートブランチ推測を無効化（checkout/switch補完の高速化）
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

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
#   Sheldon Plugin Manager
# ============================================================

# zsh-autosuggestions: プラグイン読み込み前に設定（デフォルト値の上書き）
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20        # 20文字超の入力で履歴検索を停止
ZSH_AUTOSUGGEST_MANUAL_REBIND=1           # precmd毎のウィジェット再バインドを抑制
ZSH_AUTOSUGGEST_STRATEGY=(history)        # completion strategyを使わず履歴のみ

# fast-syntax-highlighting: 512文字超のバッファでハイライトをスキップ
ZSH_HIGHLIGHT_MAXLENGTH=512

# sheldon: プラグインソースをキャッシュ（plugins.toml変更時のみ再生成）
_sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/source.zsh"
_sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
if [[ ! -f "$_sheldon_cache" || "$_sheldon_toml" -nt "$_sheldon_cache" ]]; then
  mkdir -p "${_sheldon_cache:h}"
  sheldon source > "$_sheldon_cache"
fi
source "$_sheldon_cache"
unset _sheldon_cache _sheldon_toml

# fast-syntax-highlighting: 全chromaを無効化
# chromaは各コマンド固有の高度なハイライトを提供するが、
# サブプロセス経由でコマンドを実行するため毎キーストロークのレイテンシに影響する。
# unsetにより [[ -n ... ]] チェックがfalseになりchromaブロックを完全スキップ。
# (=0 では非空文字列としてtrueになり、ブロックに入って失敗コマンドを実行していた)
# 基本的なシンタックスハイライト（コマンド/引数/パスの色分け）は維持される。
unset 'FAST_HIGHLIGHT[chroma-git]'    # git (git remote, git rev-parse等を実行)
unset 'FAST_HIGHLIGHT[chroma-hub]'    # hub (git操作)
unset 'FAST_HIGHLIGHT[chroma-lab]'    # lab (git操作)
unset 'FAST_HIGHLIGHT[chroma-docker]' # docker (サブコマンド検証)
unset 'FAST_HIGHLIGHT[chroma-make]'   # make (ターゲット検証)

# fast-syntax-highlighting: ブラケット対応チェックを無効化（毎キーストロークの文字列解析を削減）
FAST_HIGHLIGHT[use_brackets]=0

# ============================================================
#   Completions
# ============================================================

# sheldon読み込み後にcompinitを実行（プラグインのfpath拡張を反映）
# .zcompdumpは1日1回だけ再生成し、それ以外はキャッシュを利用
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# 補完結果のキャッシュ（git branch等の重い補完を高速化）
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# ドットファイル（.で始まるファイル）も補完候補に表示
setopt GLOB_DOTS

# ============================================================
#   Aliases
# ============================================================

alias vi='nvim'
alias c='cursor'
alias godot='/Applications/Godot.app/Contents/MacOS/Godot'

# colordiff
if command -v colordiff &> /dev/null; then
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
#   iTerm2 Shell Integration
# ============================================================

# 作業ディレクトリをiTerm2に通知（tmux内でもCommand+Clickでファイルを開けるようにする）
precmd_iterm2_cwd() {
  printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_iterm2_cwd

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

# zsh-autosuggestions: Ctrl+F で単語単位の部分補完（空白区切り）
# NOTE: vi-forward-blank-word等のzsh組み込みウィジェットはzsh-autosuggestionsに
# フックされており、カスタムウィジェット内から呼び出すと複数回トリガーされて
# 文字が重複する問題が発生する。そのため、BUFFER/POSTDISPLAY/CURSORを直接操作する。
_autosuggest_partial_word() {
  # サジェストがなければ通常の1文字移動
  if [[ -z "$POSTDISPLAY" ]]; then
    zle .forward-char
    return
  fi

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

}
zle -N _autosuggest_partial_word
bindkey '^F' _autosuggest_partial_word

# zsh-autosuggestions: Ctrl+E でサジェスト全体を受け入れ（サジェストがない時は行末移動）
_autosuggest_accept_or_end_of_line() {
  if [[ -n "$POSTDISPLAY" ]]; then
    # サジェストがあれば全体を受け入れ
    zle autosuggest-accept
  else
    # なければ通常の行末移動
    zle end-of-line
  fi
}
zle -N _autosuggest_accept_or_end_of_line
bindkey '^E' _autosuggest_accept_or_end_of_line

# ============================================================
#   Starship Prompt
# ============================================================
eval "$(starship init zsh)"

# ============================================================
#   Local Settings (tokens, secrets, etc.)
# ============================================================

# GITHUB_TOKEN等の秘密情報は ~/.zshrc.local に記載して読み込む
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
