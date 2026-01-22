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
#   Powerline Shell
# ============================================================

function powerline_precmd() {
  PS1="$(powerline-shell --shell zsh $?)
>++(°> "
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
  install_powerline_precmd
fi

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
#   Zinit Plugin Manager
# ============================================================

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
    print -P "%F{33} %F{34}Installation successful.%f%b" || \
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# ============================================================
#   Completions
# ============================================================

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# ============================================================
#   Google Cloud SDK
# ============================================================

[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

# ============================================================
#   Local Settings (tokens, secrets, etc.)
# ============================================================

# GITHUB_TOKEN等の秘密情報は ~/.zshrc.local に記載して読み込む
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
