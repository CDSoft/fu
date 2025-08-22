dnf_install [[
    shutter feh gimp ImageMagick scribus inkscape
    qt5-qtx11extras
    gnuplot
    qrencode
    libreoffice libreoffice-langpack-fr libreoffice-help-fr
    vokoscreenNG
    simple-scan
    evince mupdf
    atril
    xournal
    curl

    vlc ffmpeg mplayer
    gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras

    povray
]]

-- start VLC in a single instance
if fs.is_file(HOME/".config/vlc/vlcrc") then
    with_file(HOME/".config/vlc/vlcrc", function(vlcrc)
        return vlcrc:gsub('#?one%-instance=[01]', "one-instance=1")
    end)
end

-- Only Office
dnf_install [[
    https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm
]]
