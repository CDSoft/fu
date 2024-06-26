require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

local nvim_lsp = require('lspconfig')

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
    --"ccls",   -- no ccls until I can figure out how to use compile_flags.txt
    "clangd",
    "dotls",
    "pasls",
    "pyright",
    %(when(cfg.zig) [["zls",]])
    %(when(cfg.rust) [["rust_analyzer",]])
}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
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

--local sumneko_root_path = '%(repo_path)/lua-language-server'
--local sumneko_binary = sumneko_root_path.."/bin/lua-language-server"

--local runtime_path = vim.split(package.path, ';')
--table.insert(runtime_path, "lua/?.lua")
--table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.lua_ls.setup {
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
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- Teal Language Server
require'lspconfig'.teal_ls.setup{}

-- V Language Server
-- set the path to the vls installation;
local vls_root_path = "%(repo_path)/vls"
local vls_binary = vls_root_path.."/cmd/vls/vls"

require'lspconfig'.vls.setup {
  on_attach = on_attach,
  cmd = {vls_binary},
}

-- OCaml Language Server
require'lspconfig'.ocamllsp.setup {
  on_attach = on_attach,
}

-- Pascal Language Server
require'lspconfig'.pasls.setup {
  on_attach = on_attach,
}

-- Typescript Language Server
require'lspconfig'.tsserver.setup {
  on_attach = on_attach,
}

-- Purescript Language Server
require'lspconfig'.purescriptls.setup {
  on_attach = on_attach,
}

-- ELM Language Server
require'lspconfig'.elmls.setup {
  on_attach = on_attach,
}

-- Nim Language Server
require'lspconfig'.nimls.setup {
    on_attach = on_attach,
    cmd = { "%(HOME)/.nimble/bin/nimlsp" },
}

%(when(cfg.haskell) [[
-- Haskell Language Server

--require'lspconfig'.hls.setup {
--    filetypes = { 'haskell', 'lhaskell', 'cabal' },
--}


local def_opts = { noremap = true, silent = true, }
vim.g.haskell_tools = {
  hls = {
    on_attach = function(client, bufnr)
      --local opts = vim.tbl_extend('keep', def_opts, { buffer = bufnr, })
      -- haskell-language-server relies heavily on codeLenses,
      -- so auto-refresh (see advanced configuration) is enabled by default
      on_attach(client, bufnr)
      --vim.keymap.set('n', '<space>ca', vim.lsp.codelens.run, opts)
      --vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
      --vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
    end,
  },
}
]])

%(when(cfg.ocaml) [[
-- Ocaml Language Server
require'lspconfig'.ocamllsp.setup {
    on_attach = on_attach,
}
]])

require'lspconfig'.typst_lsp.setup {
}

require'lspconfig'.julials.setup {
    on_attach = on_attach,
}

-- TODO : prolog_ls seems not to work...
--[[
require'lspconfig'.prolog_ls.setup {
    on_attach = on_attach,
}
--]]
