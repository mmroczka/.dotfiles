if status is-interactive
    # Commands to run in interactive sessions can go here
    # if fisher plugin manager isn't installed, then install it
    if ! type -q fisher
        curl -sL https://git.io/fisher | source && fisher update
    end

    # ======== SETTINGS ===========
    set -g fish_escape_delay_ms 10
    set -x EDITOR nvim
    # PATHS
    # AWS CLI Setup
    set -U fish_user_paths /usr/local/Cellar/awscli/2.22.5/bin $fish_user_paths

    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    # Set the external cursor to a line. The external cursor appears when a command is started.
    # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
    set fish_cursor_external line
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block
    set fish_vi_force_cursor 1

    function extract_name
        # Get the last command in history that starts with "aws s3 cp"
        set last_command (history | grep -m 1 'aws s3 cp')
        # Use regex to extract the object name from the path
        # This assumes the object name is the last part of the local file path in the command
        echo $last_command | string match -r 'aws s3 cp [^ ]+/([^ ]+)' --groups
    end
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
    abbr -a upload --set-cursor "aws s3 cp % s3://iio-beyond-ctci-images/ --acl public-read && extract_name"

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
