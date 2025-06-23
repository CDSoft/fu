dnf_install [[
    z3
]]

if FORCE or not installed "frama-c" then
    local version = read "opam info frama-c" : lines()
        : map(function(line)
            local words = line:words()
            if words[1] == "version" then return words[2] end
        end)
        : head() : split "%." : map(tonumber)
        print("frama-c", F.show(version))
    if version:head() >= 31 then
        run "opam install alt-ergo"
        run "opam install frama-c"
    end
end
