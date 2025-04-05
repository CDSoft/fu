-- Configuration file for Neovim
-- ~/.config/nvim/init.lua

---------------------------------------------------------------------
-- Neovim configuration
---------------------------------------------------------------------

vim.g.mapleader = "," -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

local default_key_options = {
    noremap = true,
    silent = true,
}

local function key_options(opts)
    if not opts then return default_key_options end
    local t = {}
    for k,v in pairs(default_key_options) do t[k] = v end
    for k,v in pairs(opts) do t[k] = v end
    return t
end

local function xkey(x)
    return function(k, e, opts) vim.keymap.set(x, k, e, key_options(opts)) end
end

local nkey = xkey "n"
local ikey = xkey "i"
local tkey = xkey "t"

local function highlight(group)
    return function(t) vim.api.nvim_set_hl(0, group, t) end
end

local function method(t)
    return function(k)
        return function() t[k]() end
    end
end

---------------------------------------------------------------------
-- lazy.nvim -- Package manager
---------------------------------------------------------------------

-- https://github.com/folke/lazy.nvim

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

local packs = {}
local pre_config = {}
local post_config = {}

local function use(name)
    local pack = { name }
    packs[#packs+1] = pack
    return setmetatable(pack, {
        __call = function(self, opts)
            for k, v in pairs(opts) do self[k] = v end
            if opts.pre_config then pre_config[#pre_config+1] = opts.pre_config end
            if opts.post_config then post_config[#post_config+1] = opts.post_config end
            return self
        end,
    })
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd.colorscheme "lunaperche"

use "norcalli/nvim-colorizer.lua" {
    config = function()
        require'colorizer'.setup(
            {'*';},
            {
                RGB      = true;         -- #RGB hex codes
                RRGGBB   = true;         -- #RRGGBB hex codes
                names    = true;         -- "Name" codes like Blue
                RRGGBBAA = true;         -- #RRGGBBAA hex codes
                rgb_fn   = true;         -- CSS rgb() and rgba() functions
                hsl_fn   = true;         -- CSS hsl() and hsla() functions
                css      = true;         -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn   = true;         -- Enable all CSS *functions*: rgb_fn, hsl_fn
            }
        )
    end
}

use "nvim-treesitter/nvim-treesitter" {
    build = ":TSUpdate",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    post_config = function()
        highlight "Title" { fg="Red" }
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "nvim_treesitter#foldexpr()"
        vim.o.foldenable = false
    end,
}

use "https://gitlab.com/HiPhish/rainbow-delimiters.nvim"

use "nvim-lualine/lualine.nvim" {
    config = function()
        local lualine = require "lualine"
        lualine.setup {
            options = {
                icons_enabled = true,
                theme = 'onedark',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                }
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {}
        }
    end
}
use "kyazdani42/nvim-web-devicons" {
    config = function() require'nvim-web-devicons'.setup() end,
}
use "kyazdani42/nvim-tree.lua" {
    config = function() require'nvim-tree'.setup() end,
}
use "vifm/vifm.vim"

local is_a_git_repo = vim.fn.system "git rev-parse --is-inside-work-tree 2>/dev/null" ~= ""

use "nvim-telescope/telescope.nvim" {
    dependencies={
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()

        local builtin = require "telescope.builtin"

        nkey("<leader>ff", is_a_git_repo and builtin.git_files or builtin.find_files, {})
        nkey("<leader>fd", builtin.find_files, {})
        nkey("<leader>fg", builtin.live_grep, {})
        nkey("<leader>f*", builtin.grep_string, {})
        nkey("<leader>fb", builtin.buffers, {})
        nkey("<leader>f/", builtin.current_buffer_fuzzy_find, {})
        nkey("<leader>fs", builtin.git_status, {})

        nkey("<leader>lr", method(builtin)"lsp_references", {})
        nkey("<leader>ls", method(builtin)"lsp_workspace_symbols", {})
        nkey("<leader>li", method(builtin)"lsp_implementations", {})
        nkey("<leader>ld", method(builtin)"lsp_definitions", {})
        nkey("<leader>lt", method(builtin)"lsp_type_definitions", {})
        nkey("<leader>la", vim.lsp.buf.code_action, {})

        local telescope = require "telescope"
        local sorters = require "telescope.sorters"
        local previewers = require "telescope.previewers"

        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ["<Esc>"] = "close", -- single Esc to close telescope
                        ["<C-c>"] = false,
                    },
                    n = {
                    },
                },
                vimgrep_arguments = {
                    'rg',
                    '--color=auto',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case'
                },
                prompt_prefix = "> ",
                selection_caret = "> ",
                entry_prefix = "  ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "descending",
                layout_strategy = "horizontal",
                layout_config = {
                    width = 0.9,
                    height = 0.9,
                    horizontal = {
                        mirror = false,
                    },
                    vertical = {
                        mirror = false,
                    },
                },
                file_sorter = sorters.get_fuzzy_file,
                file_ignore_patterns = {},
                generic_sorter = sorters.get_generic_fuzzy_sorter,
                winblend = 0,
                border = {},
                borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
                color_devicons = true,
                use_less = true,
                path_display = {},
                set_env = { COLORTERM = 'truecolor' }, -- default = nil,
                file_previewer = previewers.vim_buffer_cat.new,
                grep_previewer = previewers.vim_buffer_vimgrep.new,
                qflist_previewer = previewers.vim_buffer_qflist.new,
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {
                        -- even more opts
                    },

                    -- pseudo code / specification for writing custom displays, like the one
                    -- for "codeactions"
                    specific_opts = {
                    --   [kind] = {
                    --     make_indexed = function(items) -> indexed_items, width,
                    --     make_displayer = function(widths) -> displayer
                    --     make_display = function(displayer) -> function(e)
                    --     make_ordinal = function(e) -> string
                    --   },
                        codeactions = true,
                    }
                }
            },
        }

        --pcall(telescope.load_extension, 'fzf')
        telescope.load_extension 'ui-select'
    end
}

--[[
use "junegunn/fzf" {
    config = function()
        nkey("<Leader>b", ":Buffers!<CR>")
        nkey("<Leader>f", ":Rg!<CR>")
        nkey("<Leader>t", ":Tags!<CR>")
        nkey("<Leader>o", is_a_git_repo and ":GFiles!<CR>" or ":Files!<CR>")
    end
}
use "junegunn/fzf.vim"
--]]

use "tpope/vim-fugitive"

--[[
use "NeogitOrg/neogit" {
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim", -- optional
        --"ibhagwan/fzf-lua",              -- optional
        --"echasnovski/mini.pick",         -- optional
    },
    config = function()
        local neogit = require "neogit"
        neogit.setup {
            -- Disables signs for sections/items/hunks
            disable_signs = false,
            -- "ascii"   is the graph the git CLI generates
            -- "unicode" is the graph like https://github.com/rbong/vim-flog
            graph_style = "unicode",
        }
    end,
}
--]]

use "lewis6991/gitsigns.nvim" {
    config = function()
        require"gitsigns".setup()
    end
}

use "https://codeberg.org/cdsoft/pwd"
use "https://codeberg.org/cdsoft/todo"

use "thinca/vim-localrc" {
    config = function()
        vim.o.exrc = true
        vim.o.secure = true
    end
}

--[==[
use "vim-pandoc/vim-pandoc" {
    post_config = function()
        vim.g["pandoc#modules#disabled"] = {"folding"}
        vim.g["pandoc#syntax#conceal#use"] = 0
        vim.g["pandoc#syntax#codeblocks#embeds#langs"] = {"c", "lua", "python", "haskell", "literatehaskell=lhaskell", "bash=sh", "dot"}

        vim.cmd.highlight "Title term=bold ctermfg=Red guifg=Red gui=bold"

        vim.cmd [[
            augroup pandoc_syntax
                au! BufNewFile,BufFilePre,BufRead *.md      set filetype=markdown.pandoc
                au! BufNewFile,BufFilePre,BufRead *.rst     set filetype=rst
                au! BufNewFile,BufFilePre,BufRead *.rst.inc set filetype=rst
            augroup END
        ]]
    end,
}
use "vim-pandoc/vim-pandoc-syntax"
use "kaarmu/typst.vim"
--]==]
use "aklt/plantuml-syntax"

use "ziglang/zig.vim" {
    config = function()
        vim.g.zig_fmt_autosave = 0
    end
}
use "JuliaEditorSupport/julia-vim"

use "metakirby5/codi.vim" {
    config = function()
        vim.g["codi#interpreters"] = {
            luax = {
                bin = {'luax'},
                prompt = '^\\(>>\\|\\.\\.\\) ',
            },
        }
    end
}

use "vim-scripts/DrawIt"

use "neovim/nvim-lspconfig" {
    config = function()

        local lspconfig = require 'lspconfig'

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

            -- Activate completion
            --require'completion'.on_attach(client)

            --Enable completion triggered by <c-x><c-o>
            buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Mappings.
            local opts = { noremap=true, silent=true }

            -- See `:help vim.lsp.*` for documentation on any of the below functions
            buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
            buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
            buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
            buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

        end

        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = {
            "bashls",
            "clangd",
            "dotls",
            "julials",
            "ocamllsp",
            "pasls",
            "pyright",
            "rust_analyzer",
            "teal_ls",
            --"typst_lsp",
            --"tinymist", -- typst
            "zls",
        }
        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 150,
                },
                settings = {
                    haskell = {
                        hlintOn = true,
                    }
                },
            }
        end

        -- Lua Language Server

        lspconfig.lua_ls.setup {
            on_attach = on_attach,
            --cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
            flags = {
                debounce_text_changes = 150,
            },
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'Lua 5.4',
                        -- Setup your lua path
                        --path = runtime_path,
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        --globals = {'vim'},
                        disable = {
                            "undefined-global",
                            "lowercase-global",
                        },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        --library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                        library = {
                            --home.."/src/luax",
                            --home.."/src/bang",
                        },
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }

    end,
}

use "hrsh7th/nvim-cmp" {
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
    },
    config = function()
        local cmp = require 'cmp'

        cmp.setup {
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                    -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
                end,
            },
            mapping = {
                ['<C-n>'] = cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Insert},
                ['<C-p>'] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Insert},
                ['<Down>'] = cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Select},
                ['<Up>'] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Select},
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,     -- only confirm explicitly selected items
                },
            },
            sources = cmp.config.sources({
                { name = 'nvim_lua' },
                { name = 'nvim_lsp' },
                -- { name = 'vsnip' }, -- For vsnip users.
                { name = 'luasnip' }, -- For luasnip users.
                -- { name = 'ultisnips' }, -- For ultisnips users.
                -- { name = 'snippy' }, -- For snippy users.
            }, {
                { name = 'buffer', keyword_length = 5 },
            }),
        }

        -- Use buffer source for `/`.
        cmp.setup.cmdline('/', {
            sources = {
                { name = 'buffer' }
            }
        })

        -- Use cmdline & path source for ':'.
        cmp.setup.cmdline(':', {
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

    end,
}

-- https://github.com/yetone/avante.nvim

local ai_provider = "%(CLAUDE_AI and 'claude' or '')"

if ai_provider ~= '' then
use "yetone/avante.nvim" {
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
        -- add any opts here
        provider = ai_provider,
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "echasnovski/mini.pick", -- for file_selector provider mini.pick
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        "ibhagwan/fzf-lua", -- for file_selector provider fzf
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
end

use "mfussenegger/nvim-dap"

use "https://codeberg.org/cdsoft/trace32-practice.vim"

for i = 1, #pre_config do pre_config[i]() end
require("lazy").setup(packs)
for i = 1, #post_config do post_config[i]() end

---------------------------------------------------------------------
-- Neovim configuration
---------------------------------------------------------------------

-- reload files if they were modified
vim.o.autoread = true
vim.cmd.autocmd "BufEnter,FocusGained * checktime"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,menuone,noinsert,noselect"

-- Startup
vim.opt.shortmess:append "mr"

-- File types / file formats

vim.cmd.runtime "spellfile"

--vim.opt.spelllang = "en,fr"
--vim.opt.spell = true

vim.cmd.autocmd "Filetype markdown setlocal spell"
vim.cmd.autocmd "Filetype markdown set spelllang=en,fr"

vim.cmd.autocmd "Filetype rst setlocal spell"
vim.cmd.autocmd "Filetype rst set spelllang=en,fr"

vim.cmd.auto "BufRead,BufNewFile *.pl set filetype=prolog"

-- Directories
vim.o.autochdir = false
vim.opt.path:append "**" -- do not use with autochdir

-- Navigation

-- Firefox like tab navigation
-- (https://vim.fandom.com/wiki/Alternative_tab_navigation)
nkey("<C-S-tab>", ":tabprevious<CR>")
nkey("<C-tab>", ":tabnext<CR>")
nkey("<C-t>", ":tabnew<CR>")
ikey("<C-S-tab>", "<ESC>:tabprevious<CR>i")
ikey("<C-tab>", "<ESC>:tabnext<CR>i")
ikey("<C-t>", "<ESC>:tabnew<CR>")

-- Windows navigation
nkey("<C-S-Left>", "<C-w>h")
nkey("<C-S-Down>", "<C-w>j")
nkey("<C-S-Up>", "<C-w>k")
nkey("<C-S-Right>", "<C-w>l")
ikey("<C-S-Left>", "<C-w>h")
ikey("<C-S-Down>", "<C-w>j")
ikey("<C-S-Up>", "<C-w>k")
ikey("<C-S-Right>", "<C-w>l")

-- Shortcuts

-- Non breakable spaces
ikey("<A-space>", "<C-v>xa0")

-- Automatic layout
vim.o.expandtab = true
vim.o.shiftround = true -- round indent to multiple of shiftwidth
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Mouse and clipboard
vim.opt.clipboard:append "unnamed"
vim.opt.clipboard:append "unnamedplus"
vim.opt.mouse = "a"

-- Search
vim.o.hlsearch = true
vim.o.ignorecase = false
vim.o.incsearch = true
vim.o.infercase = true -- when ignorecase, the completion also modifies the case
vim.o.magic = true
vim.o.showmatch = true
vim.o.smartcase = true

-- Substitutions
vim.o.inccommand = "split"

-- Window title
vim.o.title = true
vim.o.titlestring = "%f%m"

--show the current line and column in the current window
vim.cmd.autocmd "WinLeave * set nocursorline nocursorcolumn"
vim.cmd.autocmd "WinEnter * set cursorline nocursorcolumn"
vim.o.cursorline = true
vim.o.cursorcolumn = false
vim.o.equalalways = false -- do not resize other windows when splitting

vim.o.laststatus = 3
vim.o.number = true
vim.o.numberwidth = 4
vim.o.ruler = true
vim.o.showcmd = true
vim.opt.suffixes:append ".pyc"
vim.o.visualbell = true
vim.o.wildignore = "*.o,*~,*.pyc,*.bak,*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox"
vim.o.wildmenu = true
vim.o.wrap = false
vim.o.showmode = true
vim.o.completeopt = "menuone,menu,longest"
vim.o.cmdheight = 1
vim.o.listchars = "tab:›\\ ,trail:•,extends:#,nbsp:␣" -- Highlight problematic whitespace
vim.o.list = true
vim.o.colorcolumn = "120"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.lazyredraw = true

-- no line number in HTML exports
vim.g.html_number_lines = 0

-- lac scripts (*.api and *.app) are Lua scripts
vim.cmd.autocmd "BufRead,BufNewFile *.api,*.app set filetype=lua"

-- Debug terminal
vim.cmd.packadd "termdebug"
vim.g.termdebug_wide = 1

-- Terminal setup

-- tnoremap <Esc> <C-\><C-n> prevents fzf to exit with Escape
-- (see https://github.com/junegunn/fzf.vim/issues/544)
--tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"
--[[
tkey("<Esc>", function()
    local function t(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
    return vim.api.nvim_buf_get_option(0, 'filetype')=="fzf" and t"<Esc>" or t"<c-\\><c-n>"
end, {expr=true, silent=true})
--]]
tkey("<Esc>", "<c-\\><c-n>")

vim.cmd.autocmd "TermOpen * setlocal noruler|setlocal noshowcmd|setlocal nonumber|startinsert"

nkey("<C-A-t>", ":tabnew term://zsh<CR>")
ikey("<C-A-t>", "<ESC>:tabnew term://zsh<CR>")

nkey("<Leader>st", ":tabnew term://zsh<CR>")
nkey("<Leader>sn", ":split term://zsh<CR>")
nkey("<Leader>sv", ":vsplit term://zsh<CR>")

-- Global LSP configuration
vim.lsp.set_log_level("off")    -- avoid large log file (~/.local/state/nvim/lsp.log)
                                -- log levels: off, debug, trace

-- nvim startup may be too long to catch the initial SIGWINCH and resize the window
--vim.cmd [[ autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID" ]]
