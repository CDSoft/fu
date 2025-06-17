local install_lua_language_server_from_sources = false
local lua_LSP_max_memory = 1024*1024*1024
local lua_LSP_timeout = "31d"

dnf_install [[
    lua
    lua-devel
    wget
]]

--dnf_install "luarocks"

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

--[=[
luarocks "lpeg"
luarocks "luasocket luasec"
luarocks "lua-sdl2"
--]=]

-- Lua language server
if install_lua_language_server_from_sources then

    if FORCE or not installed "lua-language-server" then
        dnf_install "libstdc++-static"
        gitclone("https://github.com/LuaLS/lua-language-server", {"--recurse-submodules"})
        run {
            "cd", FU_PATH/"lua-language-server",
            "&&",
            "./make.sh",
            "&&",
            "ln -s -f $PWD/bin/lua-language-server ~/.local/bin/",
        }
        fs.remove(HOME/".local/bin/lua-language-server")
        fs.write(HOME/".local/bin/lua-language-server",
            "#!/bin/bash\n",
            "ulimit -Sv ", lua_LSP_max_memory//1024, " && \\\n",
            "exec timeout ", lua_LSP_timeout, " ", FU_PATH/"lua-language-server/bin/lua-language-server", "\n")
        fs.chmod(HOME/".local/bin/lua-language-server", fs.aR, fs.uW, fs.aX)
    end

else

    if UPDATE or not installed "lua-language-server" then
        local version = github_tag "https://github.com/LuaLS/lua-language-server/releases/latest"
        download("https://github.com/LuaLS/lua-language-server/releases/download/"..version.."/lua-language-server-"..version.."-linux-x64.tar.gz", FU_PATH/"lua-language-server-"..version.."-linux-x64.tar.gz")
        fs.mkdirs(FU_PATH/"lua-language-server-"..version.."-linux-x64")
        run {
            "tar xzf", FU_PATH/"lua-language-server-"..version.."-linux-x64.tar.gz", "-C", FU_PATH/"lua-language-server-"..version.."-linux-x64",
            "&&",
            "ln -s -f", FU_PATH/"lua-language-server-"..version.."-linux-x64/bin/lua-language-server", "~/.local/bin/",
        }
        fs.remove(HOME/".local/bin/lua-language-server")
        fs.write(HOME/".local/bin/lua-language-server",
            "#!/bin/bash\n",
            "ulimit -Sv ", lua_LSP_max_memory//1024, " && \\\n",
            "exec timeout ", lua_LSP_timeout, " ", FU_PATH/"lua-language-server-"..version.."-linux-x64/bin/lua-language-server", "\n")
        fs.chmod(HOME/".local/bin/lua-language-server", fs.aR, fs.uW, fs.aX)
    end

end

-- teal language server
--[=[
if FORCE or not installed "teal-language-server" then
    luarocks "teal-language-server"
end
--]=]
