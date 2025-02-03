#!/usr/bin/env zsh

# Enable autosuggestions
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Enable completion
autoload -Uz compinit
compinit

# Load Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Shell aliases
alias mtop="sudo mactop --interval 500 --color cyan"
alias rebuild="darwin-rebuild switch --flake . --show-trace"
alias update="nix flake update"

# Tools
alias cat="bat"
alias grep="rg"
alias find="fd"
alias ls="eza"
alias la="eza -a"
alias ll="eza -alh"
alias lt="eza --tree"

# Git
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gf="git fetch --all"
alias gpl="git pull"
alias gd="git diff"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

# Tmux
alias t="tmux"
alias ta="tmux attach -t"
alias tad="tmux attach -d -t"
alias td="tmux detach"
alias ts="tmux new-session -s"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"
alias tks="tmux kill-server"
alias tn="tmux new -s $(basename $(pwd))"

# Safety
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# Misc
alias httpc="cd ~/dev/httpc && python main.py"
alias tester="uv run pytest -vv -n 4 --dist loadscope"
alias tf_clean="rm -rfv **/.terragrunt-cache/"

# Load plugins
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [ -f /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# History settings
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Additional autoloads
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Additional useful options
setopt AUTO_RESUME          # Treat single word simple commands without redirection as candidates for resumption of an existing job
setopt NOTIFY               # Report status of background jobs immediately
setopt PROMPT_SUBST         # Parameter expansion, command substitution and arithmetic expansion in prompts
setopt AUTO_CONTINUE        # Automatically resume disowned jobs
setopt NO_HUP               # Don't kill background jobs when shell exits
setopt LONG_LIST_JOBS       # List jobs in the long format by default
setopt vi                   # Use vi key bindings in ZLE
setopt HIST_VERIFY          # Don't execute immediately upon history expansion
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate
setopt EXTENDED_GLOB        # Use extended globbing syntax

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H' backward-delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^U' backward-kill-line
bindkey '^Y' yank
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[.' insert-last-word
bindkey '^R' history-incremental-search-backward
bindkey '^I' autosuggest-accept

# Directory stack
DIRSTACKSIZE=20
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups

# GPG configuration
export GPG_TTY=$(tty)

# oh-my-posh prompt
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/tokyo-night.json)"
