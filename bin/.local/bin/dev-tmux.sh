#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <session-name> [directory]" >&2
  exit 1
fi

SESSION="$1"
DIR="${2:-$(pwd)}"

# 既存セッションがあればアタッチ
if tmux has-session -t $SESSION 2>/dev/null; then
  tmux attach -t $SESSION
  exit 0
fi

# セッション作成（ペインA）
tmux new-session -d -s $SESSION -c "$DIR"

# 右に分割（ペインB）
tmux split-window -h -t $SESSION -c "$DIR"

# ペインAを選択して下に分割（ペインC）
tmux select-pane -t $SESSION:0.0
tmux split-window -v -t $SESSION -c "$DIR"

# レイアウト調整（下を大きく）
tmux resize-pane -t $SESSION:0.2 -y 60%

# 各ペインでコマンド実行
tmux send-keys -t $SESSION:0.0 'lazygit' C-m
tmux send-keys -t $SESSION:0.1 'y' C-m
tmux send-keys -t $SESSION:0.2 'claude' C-m

tmux attach -t $SESSION
