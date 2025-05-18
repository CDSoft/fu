dnf_install "gcc gcc-c++"

-- Ninja
if UPDATE or not fs.is_file(HOME/".local/bin/ninja") then
    gitclone "https://codeberg.org/cdsoft/ninja-builder"
    run { "cd", FU_PATH/"ninja-builder", "&& ./ninja-builder.sh gcc install" }
end

-- LuaX
if UPDATE then
    gitclone "https://codeberg.org/cdsoft/luax"
    run { "cd", FU_PATH/"luax", "&& ./bootstrap.sh gcc small && ninja install" }
end

-- bang
if UPDATE or not fs.is_file(HOME/".local/bin/bang") then
    gitclone "https://codeberg.org/cdsoft/bang"
    run { "cd", FU_PATH/"bang", "&& ./boot.lua && ninja install" }
end
