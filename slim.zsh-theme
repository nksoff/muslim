# Slim
# Theme for zsh prompt

PROMPT_SLIM_SYMBOL=${PROMPT_SLIM_SYMBOL:-"❯"}
PROMPT_SLIM_SYMBOL_ROOT=${PROMPT_SLIM_SYMBOL_ROOT:-"❯❯❯"}
PROMPT_SLIM_SYMBOL_SECOND_LINE=${PROMPT_SLIM_SYMBOL_SECOND_LINE:-"·"}
PROMPT_SLIM_SYMBOL_GIT_CLEAN=${PROMPT_SLIM_SYMBOL_GIT_CLEAN:-"✓"}
PROMPT_SLIM_SYMBOL_GIT_DIRTY=${PROMPT_SLIM_SYMBOL_GIT_DIRTY:-"±"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH=${PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH:-"⬆"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PULL=${PROMPT_SLIM_SYMBOL_GIT_NEED_PULL:-"⬇"}

PROMPT_SLIM_SHOW_HOST_ALWAYS=${PROMPT_SLIM_SHOW_HOST_ALWAYS:-false}
PROMPT_SLIM_SHOW_HOST_SSH=${PROMPT_SLIM_SHOW_HOST_SSH:-true}

PROMPT_SLIM_STR_HOST=""
PROMPT_SLIM_STR_PATH=""
PROMPT_SLIM_STR_PROMPT=""
PROMPT_SLIM_STR_GIT=""

# prompt part: host
prompt_slim_part_host() {
  local show=$PROMPT_SLIM_SHOW_HOST_ALWAYS

  if $PROMPT_SLIM_SHOW_HOST_SSH; then
    [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && show=true
  fi

  if $show; then
    local host=${$(uname -n | tr 'A-Z' 'a-z')%.local}
    if [ -f ~/.hostname ]; then
        host=$(cat ~/.hostname)
    fi

    export PROMPT_SLIM_STR_HOST="%n@${host} "
  fi
}

# prompt part: path
prompt_slim_part_path() {
  export PROMPT_SLIM_STR_PATH="%~ "
}

# prompt part: prompt
prompt_slim_part_prompt() {
  export PROMPT_SLIM_STR_PROMPT="%(!.$PROMPT_SLIM_SYMBOL_ROOT.$PROMPT_SLIM_SYMBOL) "
}

# prompt part: git
prompt_slim_part_git() {
  export PROMPT_SLIM_STR_GIT=""

  if git rev-parse --git-dir > /dev/null 2>&1; then
    local time=""
    if [[ $(git log -1 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
      local last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
      local now=$(date +%s)
      local seconds_diff=$(( now - last_commit ))
      local days=$(( seconds_diff / 60 / 60 / 24 ))
      local hours=$(( seconds_diff / 60 / 60 % 24 ))
      local minutes=$(( seconds_diff / 60 % 60 ))
      (( days > 0 )) && time+="${days}d "
      (( hours > 0 )) && time+="${hours}h "
      (( minutes > 0 )) && time+="${minutes}m "
    fi

    local branch=""
    branch=$(git symbolic-ref --short HEAD 2> /dev/null) || \
    branch=$(git rev-parse --short HEAD 2> /dev/null) || \
    branch=""

    local pull_push_info=""
    local local_commit=$(git rev-parse @ 2>&1)
    local remote_commit=$(git rev-parse @{u} 2>&1)
    local common_base=$(git merge-base @ @{u} 2>&1)
    if [[ $local_commit != $remote_commit ]]; then
      if [[ $common_base == $remote_commit ]]; then
        pull_push_info="$PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH"
      elif [[ $common_base == $local_commit ]]; then
        pull_push_info="$PROMPT_SLIM_SYMBOL_GIT_NEED_PULL"
      else
        pull_push_info="$PROMPT_SLIM_SYMBOL_GIT_NEED_PULL $PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH"
      fi
    fi

    local cleanness="$PROMPT_SLIM_SYMBOL_GIT_DIRTY"
    if test -z "$(git status --porcelain --ignore-submodules)"; then
      cleanness="$PROMPT_SLIM_SYMBOL_GIT_CLEAN"
    fi

    export PROMPT_SLIM_STR_GIT="${pull_push_info} ${time} ${branch} ${cleanness}"
  fi
}

# set terminal title
prompt_slim_set_terminal_title() {
  print -n '\e]0;'
  print -Pn $1
  print -n '\a'
}

# executed after the command is read and is about to be executed
# $1 = command printed by user
# $2 = full expanded command (single-line, size-limited)
# $3 = full expanded command
prompt_slim_preexec() {
  # set terminal title = $2
  prompt_slim_set_terminal_title "${2}"
}

# executed before each prompt
prompt_slim_precmd() {
  # set terminal title = working directory
  prompt_slim_set_terminal_title '%~'

  prompt_slim_part_host
  prompt_slim_part_path
  prompt_slim_part_prompt
  prompt_slim_part_git

  # prompt itself
  PROMPT="${PROMPT_SLIM_STR_HOST}${PROMPT_SLIM_STR_PATH}
$PROMPT_SLIM_STR_PROMPT"
  RPROMPT="${PROMPT_SLIM_STR_GIT}"
}

# setup
prompt_slim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_slim_preexec
  add-zsh-hook precmd  prompt_slim_precmd
}
prompt_slim_setup
