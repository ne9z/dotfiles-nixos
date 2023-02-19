#!/bin/sh
GPG_TTY=$(tty); export GPG_TTY
export PASSWORD_STORE_GENERATED_LENGTH=8
export PASSWORD_STORE_CHARACTER_SET='[:alnum:].,'

alias y="mpv -v --script-opts=ytdl_hook-ytdl_path=$(which yt-dlp)"
alias passshow="pass show -c"
mO () {
    printf "restart: r\n"
    printf "start:   s\n"
    local choice
    read choice
    case $choice in
	r)
	    systemctl --user restart opentabletdriver
	    ;;
	s)
	    systemctl --user start opentabletdriver
	    ;;
    esac
}

doa ()
{
    doas -s
}
