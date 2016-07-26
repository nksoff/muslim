# Slim
# Theme for zsh prompt

PROMPT_SLIM_SYMBOL=${PROMPT_SLIM_SYMBOL:-"❯"}
PROMPT_SLIM_SYMBOL_SECOND_LINE=${PROMPT_SLIM_SYMBOL_SECOND_LINE:-"·"}
PROMPT_SLIM_SYMBOL_ROOT=${PROMPT_SLIM_SYMBOL_ROOT:-"❯❯❯"}
PROMPT_SLIM_SYMBOL_GIT_CLEAN=${PROMPT_SLIM_SYMBOL_GIT_CLEAN:-"✓"}
PROMPT_SLIM_SYMBOL_GIT_DIRTY=${PROMPT_SLIM_SYMBOL_GIT_DIRTY:-"±"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH=${PROMPT_SLIM_SYMBOL_GIT_NEED_PUSH:-"⬆"}
PROMPT_SLIM_SYMBOL_GIT_NEED_PULL=${PROMPT_SLIM_SYMBOL_GIT_NEED_PULL:-"⬇"}

PROMPT_SLIM_SHOW_HOST_ALWAYS=${PROMPT_SLIM_SHOW_HOST_ALWAYS:-false}
PROMPT_SLIM_SHOW_HOST_SSH=${PROMPT_SLIM_SHOW_HOST_SSH:-true}

prompt_slim_hostname() {
    tmphost=${$(uname -n)%.local}
    if [ -f ~/.hostname ]; then
        tmphost=$(cat ~/.hostname)
    fi
    echo $tmphost | tr 'A-Z' 'a-z'
}

local host=$(prompt_slim_hostname)

PROMPT_SLIM_STR_HOST="%n@${host}"
PROMPT_SLIM_STR_PATH="%~"

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

  # prompt itself
  PROMPT="${PROMPT_SLIM_STR_HOST} ${PROMPT_SLIM_STR_PATH}
  "
}

# setup
prompt_slim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_slim_preexec
  add-zsh-hook precmd  prompt_slim_precmd
}
prompt_slim_setup
