title(...)

if FORCE or not installed "zoom" then
    fs.with_tmpdir(function(tmp)
        run { "wget", "https://zoom.us/client/latest/zoom_x86_64.rpm", "-O", tmp/"zoom_x86_64.rpm" }
        run { "sudo dnf install", tmp/"zoom_x86_64.rpm" }
    end)
    mime_default "Zoom.desktop"
end
