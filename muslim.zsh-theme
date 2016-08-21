# Slim
# Theme for zsh prompt

PROMPT_MUSLIM_SYMBOL=${PROMPT_MUSLIM_SYMBOL:-"❯"}
PROMPT_MUSLIM_SYMBOL_ROOT=${PROMPT_MUSLIM_SYMBOL_ROOT:-"❯❯❯"}
PROMPT_MUSLIM_SYMBOL_SECOND_LINE=${PROMPT_MUSLIM_SYMBOL_SECOND_LINE:-"·"}
PROMPT_MUSLIM_SYMBOL_GIT_NEED_PUSH=${PROMPT_MUSLIM_SYMBOL_GIT_NEED_PUSH:-"⬆"}
PROMPT_MUSLIM_SYMBOL_GIT_NEED_PULL=${PROMPT_MUSLIM_SYMBOL_GIT_NEED_PULL:-"⬇"}
PROMPT_MUSLIM_SYMBOL_GIT_UNTRACKED=${PROMPT_MUSLIM_SYMBOL_GIT_UNTRACKED:-"◼"}
PROMPT_MUSLIM_SYMBOL_GIT_ADDED=${PROMPT_MUSLIM_SYMBOL_GIT_ADDED:-"✚"}
PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED=${PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED:-"✱"}
PROMPT_MUSLIM_SYMBOL_GIT_DELETED=${PROMPT_MUSLIM_SYMBOL_GIT_DELETED:-"✖"}
PROMPT_MUSLIM_SYMBOL_GIT_RENAMED=${PROMPT_MUSLIM_SYMBOL_GIT_RENAMED:-"➜"}
PROMPT_MUSLIM_SYMBOL_GIT_CONFLICTS=${PROMPT_MUSLIM_SYMBOL_GIT_CONFLICTS:-"!?"}

PROMPT_MUSLIM_SHOW_HOST_ALWAYS=${PROMPT_MUSLIM_SHOW_HOST_ALWAYS:-false}
PROMPT_MUSLIM_SHOW_HOST_SSH=${PROMPT_MUSLIM_SHOW_HOST_SSH:-true}

PROMPT_MUSLIM_COLOR_HOST_USER=${PROMPT_MUSLIM_COLOR_HOST_USER:-"green"}
PROMPT_MUSLIM_COLOR_HOST=${PROMPT_MUSLIM_COLOR_HOST:-"yellow"}
PROMPT_MUSLIM_COLOR_PATH=${PROMPT_MUSLIM_COLOR_PATH:-"white"}
PROMPT_MUSLIM_COLOR_PROMPT=${PROMPT_MUSLIM_COLOR_PROMPT:-"blue"}
PROMPT_MUSLIM_COLOR_PROMPT_FAIL=${PROMPT_MUSLIM_COLOR_PROMPT_FAIL:-"red"}
PROMPT_MUSLIM_COLOR_PROMPT_SECOND_LINE=${PROMPT_MUSLIM_COLOR_PROMPT_SECOND_LINE:-"blue"}
PROMPT_MUSLIM_COLOR_GIT_BRANCH=${PROMPT_MUSLIM_COLOR_GIT_BRANCH:-"green"}
PROMPT_MUSLIM_COLOR_GIT_TIME=${PROMPT_MUSLIM_COLOR_GIT_TIME:-"245"}
PROMPT_MUSLIM_COLOR_GIT_NEED_PUSH=${PROMPT_MUSLIM_COLOR_GIT_NEED_PUSH:-"yellow"}
PROMPT_MUSLIM_COLOR_GIT_NEED_PULL=${PROMPT_MUSLIM_COLOR_GIT_NEED_PULL:-"yellow"}
PROMPT_MUSLIM_COLOR_GIT_UNTRACKED=${PROMPT_MUSLIM_COLOR_GIT_UNTRACKED:-"white"}
PROMPT_MUSLIM_COLOR_GIT_ADDED=${PROMPT_MUSLIM_COLOR_GIT_ADDED:-"cyan"}
PROMPT_MUSLIM_COLOR_GIT_MODIFIED=${PROMPT_MUSLIM_COLOR_GIT_MODIFIED:-"blue"}
PROMPT_MUSLIM_COLOR_GIT_DELETED=${PROMPT_MUSLIM_COLOR_GIT_DELETED:-"red"}
PROMPT_MUSLIM_COLOR_GIT_RENAMED=${PROMPT_MUSLIM_COLOR_GIT_RENAMED:-"magenta"}
PROMPT_MUSLIM_COLOR_GIT_CONFLICTS=${PROMPT_MUSLIM_COLOR_GIT_CONFLICTS:-"yellow"}

PROMPT_MUSLIM_STR_HOST=""
PROMPT_MUSLIM_STR_PATH=""
PROMPT_MUSLIM_STR_PROMPT=""
PROMPT_MUSLIM_STR_PROMPT2=""
PROMPT_MUSLIM_STR_GIT_LEFT=""
PROMPT_MUSLIM_STR_GIT_RIGHT=""

# colorize string $w with color $1
prompt_muslim_color() {
  echo "%F{$1}$2%f"
}

# prompt part: host
prompt_muslim_part_host() {
  local show=$PROMPT_MUSLIM_SHOW_HOST_ALWAYS

  if $PROMPT_MUSLIM_SHOW_HOST_SSH; then
    [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && show=true
  fi

  if $show; then
    local host=${$(uname -n | tr 'A-Z' 'a-z')%.local}
    if [ -f ~/.hostname ]; then
        host=$(cat ~/.hostname)
    fi

    export PROMPT_MUSLIM_STR_HOST="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_HOST_USER %n)@$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_HOST $host) "
  fi
}

# prompt part: path
prompt_muslim_part_path() {
  export PROMPT_MUSLIM_STR_PATH="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_PATH %~) "
}

# prompt part: prompt
prompt_muslim_part_prompt() {
  local color="$PROMPT_MUSLIM_COLOR_PROMPT_FAIL"
  if (( $? == 0 )); then
    color="$PROMPT_MUSLIM_COLOR_PROMPT"
  fi
  local symbol="%(!.$PROMPT_MUSLIM_SYMBOL_ROOT.$PROMPT_MUSLIM_SYMBOL)"
  export PROMPT_MUSLIM_STR_PROMPT="$(prompt_muslim_color $color $symbol) "
}

# prompt part: prompt2 (second line of input, eg. run 'echo a"')
prompt_muslim_part_prompt2() {
  export PROMPT_MUSLIM_STR_PROMPT2="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_PROMPT_SECOND_LINE $PROMPT_MUSLIM_SYMBOL_SECOND_LINE) "
}

# prompt part: git -- time since last time commit
prompt_muslim_part_git__time() {
  local time=""
  if [[ $(git log -1 2>&1 > /dev/null | grep -c "^fatal: ") == 0 ]]; then
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
    time="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_TIME $time)"
  elif [[ $(git status 2> /dev/null | grep -c "Initial commit") == 1 ]]; then
    time="initial commit"
  fi
  echo $time
}

# prompt part: git -- branch
prompt_muslim_part_git__branch() {
  local branch=""
  branch=$(git symbolic-ref HEAD 2> /dev/null) || \
  branch=$(git rev-parse --short HEAD 2> /dev/null) || \
  branch=""

  echo "${branch//refs\/heads\//}"
}

# prompt part: git
prompt_muslim_part_git() {
  export PROMPT_MUSLIM_STR_GIT_LEFT=""
  export PROMPT_MUSLIM_STR_GIT_RIGHT=""

  if git rev-parse --git-dir > /dev/null 2>&1; then
    local time="$(prompt_muslim_part_git__time)"
    local branch="$(prompt_muslim_part_git__branch)"
    branch="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_BRANCH $branch)"

    local status_info="$(git status --porcelain --ignore-submodules 2> /dev/null)"

    local status_icons=""
    if $(echo "$status_info" | grep '^?? ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_UNTRACKED $PROMPT_MUSLIM_SYMBOL_GIT_UNTRACKED) "
    fi
    if $(echo "$status_info" | grep '^UU ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_CONFLICTS $PROMPT_MUSLIM_SYMBOL_GIT_CONFLICTS) "
    fi
    if $(echo "$status_info" | grep '^ D ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_DELETED $PROMPT_MUSLIM_SYMBOL_GIT_DELETED) "
    elif $(echo "$status_info" | grep '^D  ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_DELETED $PROMPT_MUSLIM_SYMBOL_GIT_DELETED) "
    fi
    if $(echo "$status_info" | grep '^.M ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_MODIFIED $PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED) "
    elif $(echo "$status_info" | grep '^AM ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_MODIFIED $PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED) "
    elif $(echo "$status_info" | grep '^M' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_MODIFIED $PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED) "
    elif $(echo "$status_info" | grep '^ T ' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_MODIFIED $PROMPT_MUSLIM_SYMBOL_GIT_MODIFIED) "
    fi
    if $(echo "$status_info" | grep '^R' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_RENAMED $PROMPT_MUSLIM_SYMBOL_GIT_RENAMED) "
    fi
    if $(echo "$status_info" | grep '^A' &> /dev/null); then
      status_icons+="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_ADDED $PROMPT_MUSLIM_SYMBOL_GIT_ADDED) "
    fi

    local local_commit="$(git rev-parse @ 2>&1)"
    local remote_commit="$(git rev-parse @{u} 2>&1)"
    local common_base="$(git merge-base @ @{u} 2>&1)"
    if [[ $local_commit != $remote_commit ]]; then
      if [[ $common_base == $remote_commit ]]; then
        pull_push_info="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_NEED_PUSH $PROMPT_MUSLIM_SYMBOL_GIT_NEED_PUSH)"
      elif [[ $common_base == $local_commit ]]; then
        pull_push_info="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_NEED_PULL $PROMPT_MUSLIM_SYMBOL_GIT_NEED_PULL)"
      else
        pull_push_info="$(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_NEED_PULL $PROMPT_MUSLIM_SYMBOL_GIT_NEED_PULL) $(prompt_muslim_color $PROMPT_MUSLIM_COLOR_GIT_NEED_PUSH $PROMPT_MUSLIM_SYMBOL_GIT_NEED_PUSH)"
      fi
      status_icons+="$pull_push_info"
    fi

    if [[ -n "${time}" ]]; then
      time=" / ${time}"
    fi

    export PROMPT_MUSLIM_STR_GIT_LEFT="$(prompt_muslim_color blue 'git'):${branch}${time}"
    export PROMPT_MUSLIM_STR_GIT_RIGHT="${status_icons}"
  fi
}

# set terminal title
prompt_muslim_set_terminal_title() {
  print -n '\e]0;'
  print -Pn $1
  print -n '\a'
}

# executed after the command is read and is about to be executed
# $1 = command printed by user
# $2 = full expanded command (single-line, size-limited)
# $3 = full expanded command
prompt_muslim_preexec() {
  # set terminal title = $2
  prompt_muslim_set_terminal_title "${2}"
}

# executed before each prompt
prompt_muslim_precmd() {
  # set terminal title = working directory
  prompt_muslim_set_terminal_title '%~'

  prompt_muslim_part_host
  prompt_muslim_part_path
  prompt_muslim_part_prompt
  prompt_muslim_part_prompt2
  prompt_muslim_part_git

  # prompt itself
  PROMPT="
 ${PROMPT_MUSLIM_STR_HOST}${PROMPT_MUSLIM_STR_PATH}${PROMPT_MUSLIM_STR_GIT_LEFT}
 ${PROMPT_MUSLIM_STR_PROMPT}"
  PROMPT2=" ${PROMPT_MUSLIM_STR_PROMPT2}"
  RPROMPT="${PROMPT_MUSLIM_STR_GIT_RIGHT}"
}

# setup
prompt_muslim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_muslim_preexec
  add-zsh-hook precmd  prompt_muslim_precmd
}
prompt_muslim_setup
