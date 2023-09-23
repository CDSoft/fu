#!/bin/bash
# vim: set ts=4 sw=4 foldmethod=marker :

########################################################################
# Fedora Updater (fu): lightweight Fedora « distribution »
#
# Copyright (C) 2018-2023 Christophe Delord
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

[ -x ~/.local/bin/luax ] || (
    HEY_URL=https://github.com/CDSoft/hey
    mkdir -p ~/.config/fu/repos
    if [ -d ~/.config/fu/repos/hey ]
    then
        ( cd ~/.config/fu/repos/hey && git fetch && git rebase )
    else
        git clone $HEY_URL ~/.config/fu/repos/hey
    fi
    ~/.config/fu/repos/hey/hey install luax
)

ln -sf "$(dirname "$(realpath "$0")")"/fu.lua ~/.local/bin/fu
~/.local/bin/luax ~/.local/bin/fu -u
