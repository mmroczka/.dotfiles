if status is-interactive
    # Commands to run in interactive sessions can go here
    # if fisher plugin manager isn't installed, then install it
    if ! type -q fisher
        curl -sL https://git.io/fisher | source && fisher update
    end

    # ======== SETTINGS ===========
    set -g fish_escape_delay_ms 10
    set -x EDITOR nvim

    # ======== ALIASES ===========
    # ls
    alias ls="eza --icons=always"
    alias ll="eza -l"
    alias lll="eza -l | less"
    alias lla="eza -la"
    alias llt="eza -T" # recurse into folder and create tree structure
    alias llfu="eza -bghHliS --git"

    # ======== ABBREVIATIONS ===========
    # TOOLING
    abbr j z
    abbr cd z

    # EDIT QUICKLY WITH NVIM
    abbr -a vim nvim
    abbr -a valias "nvim ~/.dotfiles/aliases"
    abbr -a vfunctions "nvim ~/.dotfiles/functions"
    abbr -a vkarabiner "nvim ~/.dotfiles/karabiner/karabiner.edn"
    abbr -a vzsh "nvim ~/.zshrc"

    # PYTHON
    abbr -a activate "source venv/bin/activate"

    # GIT
    abbr -a gl "git pull"
    abbr -a gp "git push"
    abbr -a gst "git status"
    abbr -a gd "git diff"
    abbr -a gb "git branch"
    abbr -a gc "git commit -v"
    abbr -a ga "git add"
    abbr -a gaa "git add --all"
    abbr -a gca "git commit -v --amend"
    abbr -a gco "git checkout"
    abbr -a glg "git log --stat"
    abbr -a glgg "git log --graph"
    abbr -a glgga "git log --graph --decorate --all"
    abbr -a glo "git log --oneline --decorate --color"
    abbr -a gloo "git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"


    # MISC
    abbr -a camera 'sudo killall AppleCameraAssistant;sudo killall VDCAssistant'
    abbr -a clear 'clear && source ~/.config/fish/config.fish'
    abbr -a c 'clear && source ~/.config/fish/config.fish'
    abbr -a e exit
    abbr cf --set-cursor --position anywhere '~/.config/fish/%'

    # better cd with autojump navigation
    zoxide init fish | source
    # fish shell cross-platform prompt
    starship init fish | source
end
