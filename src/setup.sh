#!/bin/sh
# 登录后的 shell 环境初始化
# Copyright (C) 2015-2016 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>

# This file is extracted from kde-workspace (kdm/kfrontend/genkdmconf.c)
# Copyright (C) 2001-2005 Oswald Buddenhagen <ossi@kde.org>

# Copyright (C) 2024 The Fairy Glade
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

# 注意：各 shell 对应的 logout 脚本不会被 source。
case $SHELL in
*/bash)
    [ -z "$BASH" ] && exec $SHELL "$0" "$@"
    set +o posix
    [ -f "/etc"/profile ] && . "/etc"/profile
    if [ -f "$HOME"/.bash_profile ]; then
        . "$HOME"/.bash_profile
    elif [ -f "$HOME"/.bash_login ]; then
        . "$HOME"/.bash_login
    elif [ -f "$HOME"/.profile ]; then
        . "$HOME"/.profile
    fi
    ;;
*/zsh)
    [ -z "$ZSH_NAME" ] && exec $SHELL "$0" "$@"
    [ -d "/etc"/zsh ] && zdir="/etc"/zsh || zdir="/etc"
    zhome=${ZDOTDIR:-"$HOME"}
    # zshenv 总是会被自动 source。
    [ -f "$zdir"/zprofile ] && . "$zdir"/zprofile
    [ -f "$zhome"/.zprofile ] && . "$zhome"/.zprofile
    [ -f "$zdir"/zlogin ] && . "$zdir"/zlogin
    [ -f "$zhome"/.zlogin ] && . "$zhome"/.zlogin
    emulate -R sh
    ;;
*/csh|*/tcsh)
    # [t]cshrc 总是会被自动 source。
    # 注意：在 .cshrc 之后 source csh.login 并非标准做法。
    sess_tmp=$(mktemp /tmp/sess-env-XXXXXX)
    $SHELL -c "if (-f /etc/csh.login) source /etc/csh.login; if (-f ~/.login) source ~/.login; /bin/sh -c 'export -p' >! $sess_tmp"
    . "$sess_tmp"
    rm -f "$sess_tmp"
    ;;
*/fish)
    [ -f "/etc"/profile ] && . "/etc"/profile
    [ -f "$HOME"/.profile ] && . "$HOME"/.profile
    sess_tmp=$(mktemp /tmp/sess-env-XXXXXX)
    $SHELL --login -c "/bin/sh -c 'export -p' > $sess_tmp"
    . "$sess_tmp"
    rm -f "$sess_tmp"
    ;;
*) # 纯 sh、ksh，以及任何我们无法识别的 shell。
    [ -f "/etc"/profile ] && . "/etc"/profile
    [ -f "$HOME"/.profile ] && . "$HOME"/.profile
    ;;
esac

if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    [ -f "/etc"/xprofile ] && . "/etc"/xprofile
    [ -f "$HOME"/.xprofile ] && . "$HOME"/.xprofile

    # 运行所有系统级的 xinitrc shell 脚本。
    if [ -d "/etc"/X11/xinit/xinitrc.d ]; then
        for i in "/etc"/X11/xinit/xinitrc.d/* ; do
            if [ -x "$i" ]; then
                . "$i"
            fi
        done
    fi

    if [ -d "/etc"/X11/Xresources ]; then
        for i in "/etc"/X11/Xresources/*; do
            [ -f "$i" ] && xrdb -merge "$i"
        done
    elif [ -f "/etc"/X11/Xresources ]; then
        xrdb -merge "/etc"/X11/Xresources
    fi
    [ -f "$HOME"/.Xresources ] && xrdb -merge "$HOME"/.Xresources
    [ -f "$XDG_CONFIG_HOME"/X11/Xresources ] && xrdb -merge "$XDG_CONFIG_HOME"/X11/Xresources

    # 加载 Xsession 脚本
    # 这些脚本需要 OPTIONFILE、USERXSESSION、USERXSESSIONRC 和 ALTUSERXSESSION
    # 才能正常工作
    xsessionddir="/etc"/X11/Xsession.d
    export OPTIONFILE="/etc"/X11/Xsession.options
    export USERXSESSION="$HOME"/.xsession
    export USERXSESSIONRC="$HOME"/.xsessionrc
    export ALTUSERXSESSION="$HOME"/.Xsession
    # 有些发行版的 Xsession 脚本里包含 "exec $STARTUP"，
    # 这样能确保该变量被设为我们真正想启动的内容
    export STARTUP="$@"

    if [ -d "$xsessionddir" ]; then
        for i in $(ls "$xsessionddir"); do
            script="$xsessionddir/$i"
            echo "Loading X session script $script"
            if [ -r "$script" ] && [ -f "$script" ] && expr "$i" : '^[[:alnum:]_-]\+$' > /dev/null; then
                . "$script"
            fi
        done
    fi

    if [ -f "$USERXSESSION" ]; then
        . "$USERXSESSION"
    fi
fi

exec "$@"
