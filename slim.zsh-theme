# how pwd should be shown
function _theme_pwd() {
    echo "%~"
}

# how 'user@host' should be shown:
# local: none
# ssh: user@hostname
function _theme_host() {
    local host=${$(uname -n)%.local}
    if [ -f ~/.hostname ]; then
        host=$(cat ~/.hostname)
    fi
    host=$(echo $host | tr 'A-Z' 'a-z')

    [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] &&
    echo "%{$fg[green]%}%n%{$reset_color%}@%{$fg[yellow]%}${host}%{$reset_color%} "
}

# how '$ ' prompt should be shown:
# '❯ '   for an usual
# '❯❯❯ ' for root
# color of the prompt is for last command status
function _theme_prompt() {
    echo "%(?.%{$fg[blue]%}.%{$fg[red]%})%(!.❯❯❯.❯)%{$reset_color%} %{$fg[blue]%}"
}

# the prompt
PROMPT='
$(_theme_host)$(_theme_pwd) $(git_prompt_info)
$(_theme_prompt)'

# the right-hand prompt
RPROMPT='$(git_prompt_status)%{$reset_color%}'

# git prompt info
ZSH_THEME_GIT_PROMPT_PREFIX="%B%{$fg[blue]%}git:%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%b"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◼ "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%}✱ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%}➜ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%}═ "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}⬆ "

# colors for completion and ls
if [ "x$LSCOLORS" == "x" ]; then
    export LSCOLORS='Gxfxcxdxbxegedabagacad'
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
fi
