title(...)

dnf_install [[
    fpc
    lazarus
]]

-- Free pascal language server
if FORCE or not installed "pasls" then
    dnf_install [[
        lazarus
        libsqlite3x sqlite-devel
    ]]
    gitclone("https://github.com/genericptr/pascal-language-server", {"--recurse-submodules"})
    run {
        "cd", FU_PATH/"pascal-language-server",
        "&&",
        "lazbuild src/standard/pasls.lpi",
        "&&",
        "ln -s -f", FU_PATH/"pascal-language-server/lib/x86_64-linux/pasls", "~/.local/bin/",
    }
end

