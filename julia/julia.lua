if FORCE or not installed "julia" then

    local JULIA_URL = "https://julialang.org/downloads/"
    local index = read { "curl -sSL", JULIA_URL }
    local JULIA_ARCHIVE = nil
    local JULIA_NAME
    index:gsub([[href="(https://julialang%-s3%.julialang%.org/bin/linux/x64/[0-9.]+/(julia%-[0-9.]+)%-linux%-x86_64%.tar%.gz)"]], function(path, name)
        if not JULIA_ARCHIVE then
            JULIA_ARCHIVE = path
            JULIA_NAME = name
        end
    end)
    assert(JULIA_ARCHIVE and JULIA_NAME, "Can not determine the Julia version")

    run { "wget", JULIA_ARCHIVE, "-c", "-O", "~/.local/opt"/fs.basename(JULIA_ARCHIVE) }
    run { "rm -rf", "~/.local/opt"/JULIA_NAME }
    run { "tar xzf", "~/.local/opt"/fs.basename(JULIA_ARCHIVE), "-C ~/.local/opt" }
    run { "ln -f -s", "~/.local/opt"/JULIA_NAME/"bin/julia", "~/.local/bin/julia" }

end

local project = "~/.julia/environments/nvim-lspconfig"
if FORCE or not fs.is_dir(project) then

    if not fs.is_dir(project) then
        run(([[julia --project=%s -e 'using Pkg; Pkg.add("LanguageServer")']]):format(project))
    else
        run(([[julia --project=%s -e 'using Pkg; Pkg.update()']]):format(project))
    end
    run(([[julia --project=%s -e 'using Pkg; Pkg.instantiate()']]):format(project))

end
