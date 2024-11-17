title(...)

dnf_install [[
    git git-gui gitk qgit gitg tig git-lfs
    git-delta
    subversion
    clang llvm clang-tools-extra llvm-devel clang-devel lld-devel
    cppcheck
    cmake
    ninja-build
    ncurses-devel
    readline-devel
    meld
    gtksourceview5
    pl pl-xpce pl-devel
    libev-devel startup-notification-devel xcb-util-devel xcb-util-cursor-devel xcb-util-keysyms-devel xcb-proto xcb-util-wm-devel xcb-util-xrm-devel libxkbcommon-devel libxkbcommon-x11-devel yajl-devel
    gcc-gnat
    pypy
    love
    glfw
    flex bison
    perl-ExtUtils-MakeMaker
    SDL2-devel SDL2_ttf-devel SDL2_gfx-devel SDL2_mixer-devel SDL2_image-devel SDL2_net-devel
    libpcap-devel
    libyaml libyaml-devel
    libubsan libubsan-static libasan libasan-static libtsan libtsan-static
    expect
    python3-devel
    python3-PyYAML python3-termcolor
    pkgconfig
    boost boost-devel
    libjpeg-turbo-devel libpng-devel libtiff-devel
    npm
    protobuf-devel python3-protobuf
    xz-devel zlib-devel
    blas-devel lapack-devel
    gnuplot
    openssl-devel
    golang
    libX11-devel
    libXft-devel
    octave
    libcurl-devel
    libicu-devel ncurses-devel zlib-devel
    libstdc++-static
    gc-devel
    doxygen
    graphviz
    musl-clang musl-devel musl-gcc musl-libc-static musl-libc
    pax-utils
    sassc
    glfw-devel glm-devel glew-devel
    libtool
    tokei
]]

-- git
-- https://stackoverflow.com/questions/34119866/setting-up-and-using-meld-as-your-git-difftool-and-mergetool
-- use git meld to call git difftool with meld
run "git config --global alias.meld '!git difftool -t meld --dir-diff'"
run "git config --global core.excludesfile ~/.gitignore"

if FORCE or not installed "pmccabe" then
    gitclone "https://github.com/datacom-teracom/pmccabe"
    run {
        "cd", FU_PATH/"pmccabe",
        "&&",
        "CC='gcc -Wno-implicit-function-declaration'", "make",
        "&&",
        "cp pmccabe ~/.local/bin",
    }
end
