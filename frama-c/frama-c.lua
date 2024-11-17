title(...)

dnf_install [[
    z3
]]

if FORCE or not installed "frama-c" then
    run "opam install alt-ergo"
    run "opam install frama-c"
end
