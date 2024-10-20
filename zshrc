# ZSH IS NOT MY MAIN SHELL, FISH IS. 
# Everything ZSH related is just there so life doesn't suck when I'm not using fish
# if zsh is launched, switch to fish shell, unless it was a script
WHICH_FISH="$(which fish)"
if [[ "$-" =~ i && -x "${WHICH_FISH}" && ! "${SHELL}" -ef "${WHICH_FISH}" ]]; then
  # Safeguard to only activate fish for interactive shells and only if fish
  # shell is present and executable. Verify that this is a new session by
  # checking if $SHELL is set to the path to fish. If it is not, we set
  # $SHELL and start fish.
  #
  # If this is not a new session, the user probably typed 'bash' into their
  # console and wants bash, so we skip this.
  exec env SHELL="${WHICH_FISH}" "${WHICH_FISH}" -i
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

if [[ -f ~/.aliases ]]; then
    source ~/.aliases
fi

if [[ -f ~/.functions ]]; then
    source ~/.functions
fi

# ---- Zoxide (better cd auto-jumping) ----
eval "$(zoxide init zsh)"

echo " _       __     __                             __  ___        __  ___                      __        "
echo "| |     / /__  / /________  ____ ___  ___     /  |/  /____   /  |/  /________  _________  / /______ _"
echo "| | /| / / _ \\/ / ___/ __ \\/ __ \`__ \\/ _ \\   / /|_/ / ___/  / /|_/ / ___/ __ \\/ ___/_  / / //_/ __ \`/"
echo "| |/ |/ /  __/ / /__/ /_/ / / / / / /  __/  / /  / / /     / /  / / /  / /_/ / /__  / /_/ ,< / /_/ / "
echo "|__/|__/\\___/_/\\___/\\____/_/ /_/ /_/\\___/  /_/  /_/_(_)   /_/  /_/_/   \\____/\\___/ /___/_/|_|\\__,_/  "


