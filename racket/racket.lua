if FORCE or not installed "racket" then

    local RACKET_URL = "https://download.racket-lang.org/"
    local index = read  { "curl -sSL", RACKET_URL }
    local RACKETINST = nil
    local RACKET_NAME
    index:gsub([["([0-9.]+/(racket%-[0-9.]+)%-x86_64%-linux%-cs%.sh)"]], function(path, name)
        if not RACKETINST then
            RACKETINST = "https://mirror.racket-lang.org/installers/"..path
            RACKET_NAME = name
        end
    end)
    assert(RACKETINST and RACKET_NAME, "Can not determine the Racket version")

    run { "wget", RACKETINST, "-c", "-O", "~/.local/opt"/fs.basename(RACKETINST) }
    run { "sh", "~/.local/opt"/fs.basename(RACKETINST), "--in-place", "--dest", "~/.local/opt"/RACKET_NAME }
    for _, exe in ipairs { "racket", "drracket", "raco" } do
        run { "ln -f -s", "~/.local/opt"/RACKET_NAME/"bin"/exe, "~/.local/bin"/exe }
    end

end
