if FORCE or not installed "nim" or not fs.is_file(HOME/".nimble/bin/nimlsp") then

    local NIM_URL = "https://nim-lang.org/install_unix.html"
    local index = pipe("curl -sSL %(NIM_URL)")
    local NIM_ARCHIVE = nil
    local NIM_DIR
    index:gsub([[(download/(nim%-[0-9.]+)%-linux_x64%.tar%.xz)]], function(url, name)
        if not NIM_ARCHIVE then
            NIM_ARCHIVE = dirname(NIM_URL)..url
            NIM_DIR = name
        end
    end)
    assert(NIM_ARCHIVE and NIM_DIR, "Can not determine Nim version")
    local curr_version = read("nim --version || true"):match("Version ([%d%.]+)")
    local version = NIM_ARCHIVE:match("nim%-([%d%.]+)")

    if version ~= curr_version then
        run { "wget", NIM_ARCHIVE, "-c", "-O", "~/.local/opt"/fs.basename(NIM_ARCHIVE) }
        run { "rm -rf", "~/.local/opt"/NIM_DIR }
        run { "tar xJf", "~/.local/opt"/fs.basename(NIM_ARCHIVE), "-C ~/.local/opt" }
        run { "ln -f -s", "~/.local/opt"/NIM_DIR/"bin/nim", "~/.local/bin/nim" }
        run { "ln -f -s", "~/.local/opt"/NIM_DIR/"bin/nimble", "~/.local/bin/nimble" }
        run { "ln -f -s", "~/.local/opt"/NIM_DIR/"bin/nimsuggest", "~/.local/bin/nimsuggest" }
    end

    -- nimlsp
    run { "~/.local/opt/nim-"..NIM_VERSION/"bin/nimble", "install nimlsp" }

end
