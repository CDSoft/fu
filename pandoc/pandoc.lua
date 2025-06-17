dnf_install [[
    patat
    wkhtmltopdf
    aspell-fr aspell-en
    figlet
    translate-shell
]]

-- Pandoc
if UPDATE or not fs.is_file(HOME/".local/bin/pandoc") then
    local version = github_tag "https://github.com/jgm/pandoc/releases/latest"
    local curr_version = read "pandoc --version || true":words()[2]
    if version ~= curr_version then
        local url = "https://github.com/jgm/pandoc/releases/download/"..version.."/pandoc-"..version.."-linux-amd64.tar.gz"
        download(url, FU_PATH/url:basename())
        run { "tar -C ~/.local -xzvf", FU_PATH/url:basename(), "--strip-components=1" }
    end
end

-- PlantUML
if FORCE or not fs.is_file(HOME/".local/bin/plantuml.jar") then
    local index = download "https://plantuml.com/fr/download"
    local latest = assert(index : match 'href="(https://[^"]+%.jar)"')
    local content = download(latest)
    fs.write_bin(HOME/".local/bin/plantuml.jar", content)
end

-- ditaa
if FORCE or not fs.is_file(HOME/".local/bin/ditaa.jar") then
    local index = download "https://github.com/stathissideris/ditaa/releases/latest"
    local tag = assert(index : match "releases/tag/v([%d%.]+)")
    local content = download("https://github.com/stathissideris/ditaa/releases/download/v"..tag.."/ditaa-"..tag.."-standalone.jar")
    fs.write_bin(HOME/".local/bin/ditaa.jar", content)
end

-- lsvg
if UPDATE or not fs.is_file(HOME/".local/bin/lsvg") then
    gitclone "https://codeberg.org/cdsoft/lsvg"
    run { "cd", FU_PATH/"lsvg", "&& bang && ninja install" }
end

-- panda
if UPDATE or not fs.is_file(HOME/".local/bin/panda") then
    gitclone "https://codeberg.org/cdsoft/panda"
    run { "cd", FU_PATH/"panda", "&& bang && ninja install" }
end

-- npm modules (mainly for HTML to PDF conversion)
npm_install "chrome-launcher chrome-remote-interface"
