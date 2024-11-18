title(...)

dnf_install [[
    gcc gcc-c++ gmp gmp-devel make ncurses ncurses-compat-libs xz perl
]]

-- GHCup
if FORCE or not installed "ghcup" then
    run {
        "export BOOTSTRAP_HASKELL_NONINTERACTIVE=1;",
        "export BOOTSTRAP_HASKELL_INSTALL_HLS=1;",
        "curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh",
    }
end

local HASKELL_STACK_PACKAGES = {
    "hasktags",
    "hlint",
    "hoogle",
    --"matplotlib",
    --"gnuplot",
    "parallel",
    "MissingH",
    "timeit",
}
if FORCE then
    for _, package in ipairs(HASKELL_STACK_PACKAGES) do
        run { ". ~/.ghcup/env; ghcup run stack install --", package }
    end
end

local HASKELL_CABAL_PACKAGES = {
    "implicit-hie",
}
if FORCE then
    for _, package in ipairs(HASKELL_CABAL_PACKAGES) do
        run { ". ~/.ghcup/env; ghcup run cabal install -- --overwrite-policy=always", package }
    end
end
