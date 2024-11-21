dnf_install [[
    lua
    luarocks
    lua-devel

]]

--[=[
luarocks [[
    ansicolors
    bigint
    cprint
    fun
    lcomplex
    lpeg
    lua-basex
    lua-cURL
    luafilesystem
    lua_fun
    lua-gnuplot
    lua-protobuf
    luarepl
    luasocket
    lua-term
    lua-toml
    lua-yaml
    lyaml
    map
    optparse
    penlight
    stdlib
    tcc
]]
--]=]

if FORCE or not fs.is_file(HOME/".luarocks/lib64/lua/5.4/SDL.so") then
    luarocks "lua-sdl2"
end

-- Lua language server
if FORCE or not installed "lua-language-server" then
    gitclone("https://github.com/LuaLS/lua-language-server", {"--recurse-submodules"})
    run {
        "cd", FU_PATH/"lua-language-server",
        "&&",
        "./make.sh",
        "&&",
        "ln -s -f $PWD/bin/lua-language-server ~/.local/bin/",
    }
end

-- teal language server
if FORCE or not installed "teal-language-server" then
    luarocks "teal-language-server"
end
