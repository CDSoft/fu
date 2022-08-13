#!/bin/bash
# vim: set ts=4 sw=4 foldmethod=marker :

########################################################################
# Fedora Updater (fu): lightweight Fedora « distribution »
#
# Copyright (C) 2018-2022 Christophe Delord
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

mkdir -p ~/.local/bin

[ -x ~/.local/bin/zig ] || (
    ZIG_VERSION=0.9.1
    ZIG_URL=https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz
    mkdir -p ~/.local/opt/
    cd ~/.local/opt/
    wget $ZIG_URL -O $(basename $ZIG_URL)
    tar xJf $(basename $ZIG_URL)
    ln -sf ~/.local/opt/$(basename $ZIG_URL .tar.xz)/zig ~/.local/bin/zig
)

[ -x ~/.local/bin/luax ] || (
    LUAX_URL=https://github.com/CDSoft/luax
    TMP_LUAX=$(mktemp -d)
    cd $TMP_LUAX
    git clone $LUAX_URL
    cd luax
    make install
)

ln -sf "$(dirname "$(realpath "$0")")"/fu.lua ~/.local/bin/fu
~/.local/bin/luax ~/.local/bin/fu -u
