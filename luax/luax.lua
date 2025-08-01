dnf_install [[
    gcc gcc-c++
    curl
    luarocks
]]

luarocks [[
    luasocket
    luasec
]]

-- Ninja
if UPDATE or not fs.is_file(HOME/".local/bin/ninja") then
    gitclone "https://codeberg.org/cdsoft/ninja-builder"
    run { "cd", FU_PATH/"ninja-builder", "&& ./ninja-builder.sh gcc install" }
end

-- LuaX
if UPDATE then
    gitclone "https://codeberg.org/cdsoft/luax"
    run { "cd", FU_PATH/"luax", "&& ./bootstrap.sh cross && ninja install" }
    run { HOME/".local/bin/luax postinstall" }
end

-- bang
if UPDATE or not fs.is_file(HOME/".local/bin/bang") then
    gitclone "https://codeberg.org/cdsoft/bang"
    run { "cd", FU_PATH/"bang", "&& ./boot.lua && ninja install" }
end
