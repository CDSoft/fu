if not db.wiki then
    db.wiki = db.wiki or HOME/"sync/notes"
    db:save()
end

dnf_install "syncthing"
