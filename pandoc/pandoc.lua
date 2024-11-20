dnf_install [[
    patat
    wkhtmltopdf
    aspell-fr aspell-en
    figlet
    translate-shell
]]

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
