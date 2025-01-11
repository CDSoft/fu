-- Ninja
if UPDATE or not fs.is_file(HOME/".local/bin/ninja") then
    dnf_install "gcc"
    gitclone "https://github.com/CDSoft/ninja-builder"
    run {
        "cd", FU_PATH/"ninja-builder",
        "&& ./ninja-builder.sh gcc install",
    }
end

-- LuaX
if UPDATE then
    gitclone "https://github.com/CDSoft/luax"
    run { "cd", FU_PATH/"luax", "&& ./bootstrap.sh gcc small && ninja install" }
end

-- bang
if UPDATE or not fs.is_file(HOME/".local/bin/bang") then
    gitclone "https://github.com/CDSoft/bang"
    run { "cd", FU_PATH/"bang", "&& ./boot.lua && ninja install" }
end
