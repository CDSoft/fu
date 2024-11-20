local asymptote_sources = false

if asymptote_sources then
    if FORCE or not fs.is_file(HOME/".local/bin/asy") then
        gitclone "https://github.com/vectorgraphics/asymptote"
        run { "cd", FU_PATH/"asymptote", "&&", "./autogen.sh" }
        run { "cd", FU_PATH/"asymptote", "&&", "./configure", "--prefix="..HOME/".local" }
        run { "cd", FU_PATH/"asymptote", "&&", "make all -j 4" }
        run { "cd", FU_PATH/"asymptote", "&&", "make install" }
    end
else
    dnf_install "asymptote"
end

-- Asymptote syntax
local function nvim_cp(candidates, dest)
    for _, src in ipairs(candidates) do
        if fs.is_file(src) then
            fs.mkdirs(fs.dirname(dest))
            fs.copy(src, dest)
            return
        end
    end
end
-- Asymptote syntax
nvim_cp(
    { HOME/".local/share/asymptote/asy.vim",
        "/usr/share/asymptote/asy.vim",
        "/usr/share/vim/addons/syntax/asy.vim",
    },
    HOME/".config/nvim/syntax/asy.vim"
)
-- Asymptote syntax detection
nvim_cp(
    { HOME/".local/share/asymptote/asy_filetype.vim",
        "/usr/share/asymptote/asy_filetype.vim",
        "/usr/share/vim/addons/ftdetect/asy_filetype.vim",
    },
    HOME/".config/nvim/ftdetect/asy_filetype.vim"
)
