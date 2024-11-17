title(...)

local install_sources = false

if install_sources then

    if FORCE or not fs.is_file(HOME/".local/bin/swipl") then

        -- https://www.swi-prolog.org/build/unix.html
        dnf_install [[
            cmake
            ninja-build
            libunwind
            gperftools-devel
            freetype-devel
            gmp-devel
            java-1.8.0-openjdk-devel
            java-11-openjdk-devel
            jpackage-utils
            libICE-devel
            libjpeg-turbo-devel
            libSM-devel
            libX11-devel
            libXaw-devel
            libXext-devel
            libXft-devel
            libXinerama-devel
            libXmu-devel
            libXpm-devel
            libXrender-devel
            libXt-devel
            ncurses-devel
            openssl-devel
            pkgconfig
            readline-devel
            libedit-devel
            unixODBC-devel
            zlib-devel
            uuid-devel
            libuuid-devel
            libarchive-devel
            libyaml-devel
        ]]

        gitclone "https://github.com/SWI-Prolog/swipl-devel.git"
        run {
            "cd", FU_PATH/"swipl-devel",
            "&&",
            "git submodule update --init",
        }
        fs.mkdirs(FU_PATH/"swipl-devel/build")
        run {
            "cd", FU_PATH/"swipl-devel/build",
            "&&",
            "cmake", "-DCMAKE_INSTALL_PREFIX="..HOME/".local", "-G Ninja", "..",
            "&&",
            "ninja",
            "&&",
            "ninja install",
        }
    end

else

    dnf_install [[
        swi-prolog
        swi-prolog-x
    ]]

end

-- SWI Prolog language server
if FORCE or not fs.is_file(HOME/".local/share/swi-prolog/pack/lsp_server/prolog/lsp_server.pl") then
    run "swipl -g 'pack_install(lsp_server)' -t 'halt'"
end
