-- FileExt shows two extensions when the file is an archive

local added = vifm.addcolumntype {
    name = 'FileExt',
    handler = function(info)
        local e = info.entry
        if e.isdir then return { text = "<dir>" } end
        local name1 = vifm.fnamemodify(e.name, ':r')
        local ext1  = vifm.fnamemodify(e.name, ':e')
        local ext2  = vifm.fnamemodify(name1, ':e')
        local ext =
            #ext2>0 and ext1:match"%.?[gxl]z$"
                and ext2.."."..ext1
                or ext1
        if #ext >= info.width then
            ext = "…"..ext:sub(#ext-info.width+2)
        end
        return { text = ext }
    end,
}
if not added then
    vifm.sb.error("Failed to add FileExt view column")
end

return {}
