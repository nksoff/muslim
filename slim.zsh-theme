# Slim
# Theme for zsh prompt

PROMPT_SLIM_SYMBOL=${PROMPT_SLIM_SYMBOL:-"❯"}
PROMPT_SLIM_SYMBOL_ROOT=${PROMPT_SLIM_SYMBOL_ROOT:-"❯❯❯"}
PROMPT_SLIM_SYMBOL_SECOND_LINE=${PROMPT_SLIM_SYMBOL_SECOND_LINE:-"·"}
PROMPT_SLIM_SYMBOL_GIT_CLEAN=${PROMPT_SLIM_SYMBOL_GIT_CLEAN:-"✓"}
PROMPT_SLIM_SYMBOL_GIT_DIRTY=${PROMPT_SLIM_SYMBOL_GIT_DIRTY:-"✱"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH=${PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH:-"⬆"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PULL=${PROMPT_SLIM_SYMBOL_GIT_NEED_PULL:-"⬇"}

PROMPT_SLIM_SHOW_HOST_ALWAYS=${PROMPT_SLIM_SHOW_HOST_ALWAYS:-false}
PROMPT_SLIM_SHOW_HOST_SSH=${PROMPT_SLIM_SHOW_HOST_SSH:-true}

PROMPT_SLIM_COLOR_HOST_USER=${PROMPT_SLIM_COLOR_HOST_USER:-"green"}
PROMPT_SLIM_COLOR_HOST=${PROMPT_SLIM_COLOR_HOST:-"yellow"}
PROMPT_SLIM_COLOR_PATH=${PROMPT_SLIM_COLOR_PATH:-"white"}
PROMPT_SLIM_COLOR_PROMPT=${PROMPT_SLIM_COLOR_PROMPT:-"blue"}
PROMPT_SLIM_COLOR_PROMPT_FAIL=${PROMPT_SLIM_COLOR_PROMPT_FAIL:-"red"}
PROMPT_SLIM_COLOR_PROMPT_SECOND_LINE=${PROMPT_SLIM_COLOR_PROMPT_SECOND_LINE:-"blue"}
PROMPT_SLIM_COLOR_GIT_BRANCH=${PROMPT_SLIM_COLOR_GIT_BRANCH:-"green"}
PROMPT_SLIM_COLOR_GIT_NEED_PUSH=${PROMPT_SLIM_COLOR_GIT_NEED_PUSH:-"yellow"}
PROMPT_SLIM_COLOR_GIT_NEED_PULL=${PROMPT_SLIM_COLOR_GIT_NEED_PULL:-"yellow"}
PROMPT_SLIM_COLOR_GIT_CLEAN=${PROMPT_SLIM_COLOR_GIT_CLEAN:-"green"}
PROMPT_SLIM_COLOR_GIT_DIRTY=${PROMPT_SLIM_COLOR_GIT_DIRTY:-"blue"}
PROMPT_SLIM_COLOR_GIT_TIME=${PROMPT_SLIM_COLOR_GIT_TIME:-"245"}

PROMPT_SLIM_STR_HOST=""
PROMPT_SLIM_STR_PATH=""
PROMPT_SLIM_STR_PROMPT=""
PROMPT_SLIM_STR_PROMPT2=""
PROMPT_SLIM_STR_GIT_LEFT=""
PROMPT_SLIM_STR_GIT_RIGHT=""

# colorize string $w with color $1
prompt_slim_color() {
  echo "%F{$1}$2%f"
}

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

    export PROMPT_SLIM_STR_HOST="$(prompt_slim_color $PROMPT_SLIM_COLOR_HOST_USER %n)@$(prompt_slim_color $PROMPT_SLIM_COLOR_HOST $host) "
  fi
}

# prompt part: path
prompt_slim_part_path() {
  export PROMPT_SLIM_STR_PATH="$(prompt_slim_color $PROMPT_SLIM_COLOR_PATH %~) "
}

# prompt part: prompt
prompt_slim_part_prompt() {
  local color="%(?.$PROMPT_SLIM_COLOR_PROMPT.$PROMPT_SLIM_COLOR_PROMPT_FAIL)"
  local symbol="%(!.$PROMPT_SLIM_SYMBOL_ROOT.$PROMPT_SLIM_SYMBOL)"
  export PROMPT_SLIM_STR_PROMPT="$(prompt_slim_color $color $symbol) "
}

# prompt part: prompt2 (second line of input, eg. run 'echo a"')
prompt_slim_part_prompt2() {
  export PROMPT_SLIM_STR_PROMPT2="$(prompt_slim_color $PROMPT_SLIM_COLOR_PROMPT_SECOND_LINE $PROMPT_SLIM_SYMBOL_SECOND_LINE) "
}

# prompt part: git
prompt_slim_part_git() {
  export PROMPT_SLIM_STR_GIT_LEFT=""
  export PROMPT_SLIM_STR_GIT_RIGHT=""

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
      (( minutes > 0 )) && time+="${minutes}m"
      [ -z $time ] && time+="<1m"
      time="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_TIME $time)"
    fi

    local branch=""
    branch=$(git symbolic-ref --short HEAD 2> /dev/null) || \
    branch=$(git rev-parse --short HEAD 2> /dev/null) || \
    branch=""

    branch="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_BRANCH $branch)"

    local pull_push_info=""
    local local_commit="$(git rev-parse @ 2>&1)"
    local remote_commit="$(git rev-parse @{u} 2>&1)"
    local common_base="$(git merge-base @ @{u} 2>&1)"
    if [[ $local_commit != $remote_commit ]]; then
      if [[ $common_base == $remote_commit ]]; then
        pull_push_info="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_NEED_PUSH $PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH)"
      elif [[ $common_base == $local_commit ]]; then
        pull_push_info="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_NEED_PULL $PROMPT_SLIM_SYMBOL_GIT_NEED_PULL)"
      else
        pull_push_info="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_NEED_PULL $PROMPT_SLIM_SYMBOL_GIT_NEED_PULL) $(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_NEED_PUSH $PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH)"
      fi
    fi

    local cleanness="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_DIRTY $PROMPT_SLIM_SYMBOL_GIT_DIRTY)"
    if test -z "$(git status --porcelain --ignore-submodules)"; then
      cleanness="$(prompt_slim_color $PROMPT_SLIM_COLOR_GIT_CLEAN $PROMPT_SLIM_SYMBOL_GIT_CLEAN)"
    fi

    export PROMPT_SLIM_STR_GIT_LEFT="$(prompt_slim_color blue 'git'):$branch / ${time}"
    export PROMPT_SLIM_STR_GIT_RIGHT="${pull_push_info} ${cleanness}"
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
  prompt_slim_part_prompt2
  prompt_slim_part_git

  # prompt itself
  PROMPT="
${PROMPT_SLIM_STR_HOST}${PROMPT_SLIM_STR_PATH}${PROMPT_SLIM_STR_GIT_LEFT}
${PROMPT_SLIM_STR_PROMPT}"
  PROMPT2="${PROMPT_SLIM_STR_PROMPT2}"
  RPROMPT="${PROMPT_SLIM_STR_GIT_RIGHT}"
}

# setup
prompt_slim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_slim_preexec
  add-zsh-hook precmd  prompt_slim_precmd
}
prompt_slim_setup
