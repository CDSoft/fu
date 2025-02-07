-- FileExt shows two extensions when the file is an archive

local max_len = 4

local compressed = {
    gz   = true,
    bz2  = true,
    xz   = true,
    lz   = true,
    lz4  = true,
    lzma = true,
    lzo  = true,
    zst  = true,
    z    = true,
}

local added = vifm.addcolumntype {
    name = 'FileExt',
    handler = function(info)
        local e = info.entry
        if e.isdir then return { text = e.name==".." and "" or "" } end
        local name1 = vifm.fnamemodify(e.name, ':r')
        local ext1  = vifm.fnamemodify(e.name, ':e')
        local ext2  = vifm.fnamemodify(name1, ':e')
        local ext
        if #ext1 > max_len then
            ext = ""
        elseif #ext2>0 and compressed[ext1:lower()] then
            ext = ext2.."."..ext1
        else
            ext = ext1
        end
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
