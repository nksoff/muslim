# Slim
# Theme for zsh prompt

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
}

# setup
prompt_slim_setup() {
  autoload -U add-zsh-hook

  # pre-hooks
  add-zsh-hook preexec prompt_slim_preexec
  add-zsh-hook precmd  prompt_slim_precmd
}
prompt_slim_setup
