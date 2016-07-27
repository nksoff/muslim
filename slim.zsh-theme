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
  export PROMPT_SLIM_STR_PROMPT=""
}

# prompt part: git
prompt_slim_part_git() {
  export PROMPT_SLIM_STR_GIT=""
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
  PROMPT="${PROMPT_SLIM_STR_HOST}${PROMPT_SLIM_STR_PATH} "
}

# setup
prompt_slim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_slim_preexec
  add-zsh-hook precmd  prompt_slim_precmd
}
prompt_slim_setup
