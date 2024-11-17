title(...)

-- Typescript language server
if FORCE or not installed "typescript-language-server" then
    fs.mkdirs(HOME/".local/opt/typescript-language-server")
    run [[ cd ~/.local/opt/typescript-language-server &&
            npm install typescript typescript-language-server &&
            ln -s -f $PWD/node_modules/.bin/tsc ~/.local/bin/ &&
            ln -s -f $PWD/node_modules/.bin/typescript-language-server ~/.local/bin/
    ]]
end

-- Purescript language server
if FORCE or not installed "purescript-language-server" then
    fs.mkdirs(HOME/".local/opt/purescript-language-server")
    run [[ cd ~/.local/opt/purescript-language-server &&
            npm install purescript spago purescript-language-server &&
            ln -s -f $PWD/node_modules/.bin/purs ~/.local/bin/ &&
            ln -s -f $PWD/node_modules/.bin/spago ~/.local/bin/ &&
            ln -s -f $PWD/node_modules/.bin/purescript-language-server ~/.local/bin/
    ]]
end

-- ELM language server
if FORCE or not installed "elm-language-server" then
    fs.mkdirs(HOME/".local/opt/elm-language-server")
    run [[ cd ~/.local/opt/elm-language-server &&
            npm install elm elm-test elm-format @elm-tooling/elm-language-server &&
            ln -s -f $PWD/node_modules/.bin/elm ~/.local/bin/ &&
            ln -s -f $PWD/node_modules/.bin/elm-language-server ~/.local/bin/
    ]]
end
