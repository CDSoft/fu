#!/bin/bash
# vim: set ts=4 sw=4 foldmethod=marker :

########################################################################
# Fedora Updater (fu): lightweight Fedora « distribution »
#
# Copyright (C) 2018-2020 Christophe Delord
# https://github.com/CDSoft/fu
#
# This file is part of Fedora Updater (FU)
#
# FU is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# FU is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FU.  If not, see <http://www.gnu.org/licenses/>.
########################################################################

if ! sudo true
then
    su -c "
        echo '%sudo ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-sudo;
        chmod 440 /etc/sudoers.d/10-sudo;
        usermod -a -G sudo $USER;
        "
    newgrp sudo
    exec "$@"
fi


[ -x ~/.local/bin/lua ] || (
    ( hash apt && ! ( hash curl && hash make && hash gcc ) ) 2>/dev/null && sudo apt install curl make gcc
    ( hash dnf && ! ( hash curl && hash make && hash gcc ) ) 2>/dev/null && sudo dnf install curl make gcc
    LUA_VERSION=5.4.3
    LUA_BUILD=/tmp/fu-lua-$LUA_VERSION
    mkdir -p $LUA_BUILD
    cd $LUA_BUILD
    curl -R -O http://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz
    rm -rf lua-$LUA_VERSION
    tar zxf lua-$LUA_VERSION.tar.gz
    cd lua-$LUA_VERSION
    sed -i 's#^INSTALL_TOP=.*#INSTALL_TOP=~/.local#' Makefile
    make linux test install
)

ln -sf "$(dirname "$(realpath "$0")")"/fu.lua ~/.local/bin/fu
~/.local/bin/lua ~/.local/bin/fu -u
