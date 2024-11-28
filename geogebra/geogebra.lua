if FORCE or not installed "geogebra" then
    local GEOGEBRA_URL = "https://download.geogebra.org/installers/6.0/"
    local GEOGEBRA_ARCHIVE
    download(GEOGEBRA_URL):gsub('href="(GeoGebra%-Linux64%-Portable%-(.-)%.zip)"', function(archive)
        GEOGEBRA_ARCHIVE = GEOGEBRA_URL/archive
    end)
    if not fs.is_file(HOME/".local/opt"/GEOGEBRA_ARCHIVE:basename()) then
        download(GEOGEBRA_ARCHIVE, HOME/".local/opt"/GEOGEBRA_ARCHIVE:basename())
    end
    run { "cd ~/.local/opt/", "&&", "rm -rf GeoGebra-linux-x64", "&&", "unzip", GEOGEBRA_ARCHIVE:basename() }
    run { "ln -f -s ~/.local/opt/GeoGebra-linux-x64/GeoGebra ~/.local/bin/geogebra" }
end
