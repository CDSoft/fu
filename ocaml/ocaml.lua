title(...)

dnf_install [[
    opam
]]

local packages = "dune ocaml-lsp-server odoc ocamlformat utop"

if not fs.is_file(HOME/".opam/config") then
    run "opam init"
    run "opam update && opam upgrade"
    run { "opam install", packages }
elseif FORCE then
    run "opam update && opam upgrade"
    run { "opam install", packages }
end
