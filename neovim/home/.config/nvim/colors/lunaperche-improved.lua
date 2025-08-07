-- Colorscheme basé sur lunaperche avec améliorations
-- Nom: lunaperche-improved
-- Auteur: Adaptation personnalisée

-- Couleurs de base du thème lunaperche
local colors = {
  -- Couleurs de fond
  bg = "#0f0f23",           -- Fond principal
  bg_alt = "#181825",       -- Fond alternatif
  bg_highlight = "#1e1e2e", -- Fond surligné

  -- Couleurs de premier plan
  fg = "#cdd6f4",           -- Texte principal
  fg_alt = "#a6adc8",       -- Texte secondaire
  fg_dim = "#585b70",       -- Texte atténué

  -- Couleurs d'accent
  blue = "#89b4fa",         -- Bleu principal
  lavender = "#b4befe",     -- Lavande
  sapphire = "#74c7ec",     -- Saphir
  sky = "#89dceb",          -- Ciel
  teal = "#94e2d5",         -- Sarcelle
  green = "#a6e3a1",        -- Vert
  yellow = "#f9e2af",       -- Jaune
  peach = "#fab387",        -- Pêche
  maroon = "#eba0ac",       -- Marron
  red = "#f38ba8",          -- Rouge
  mauve = "#cba6f7",        -- Mauve
  pink = "#f5c2e7",         -- Rose
  flamingo = "#f2cdcd",     -- Flamant
  rosewater = "#f5e0dc",    -- Eau de rose

  -- Couleurs spéciales
  overlay0 = "#6c7086",     -- Overlay niveau 0
  overlay1 = "#7f849c",     -- Overlay niveau 1
  overlay2 = "#9399b2",     -- Overlay niveau 2
  surface0 = "#313244",     -- Surface niveau 0
  surface1 = "#45475a",     -- Surface niveau 1
  surface2 = "#585b70",     -- Surface niveau 2

  -- CORRECTION: Numéros de ligne plus clairs
  line_number = "#9399b2",      -- Plus clair que l'original
  line_number_current = "#cdd6f4", -- Ligne actuelle bien visible

  -- CORRECTION: Bordures de fenêtre avec fond approprié
  win_separator = "#585b70",    -- Couleur du séparateur
}

-- Configuration des groupes de surbrillance
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "lunaperche-improved"

local groups = {
    -- Interface de base
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.bg_alt },
    NormalNC = { fg = colors.fg_alt, bg = colors.bg },

    -- CORRECTION: Numéros de ligne améliorés
    LineNr = { fg = colors.line_number, bg = colors.bg },
    CursorLineNr = { fg = colors.line_number_current, bg = colors.bg, bold = true },

    -- CORRECTION: Bordures de fenêtre corrigées
    WinSeparator = { fg = colors.win_separator, bg = colors.bg },
    VertSplit = { fg = colors.win_separator, bg = colors.bg },
    FloatBorder = { fg = colors.win_separator, bg = colors.bg_alt },

    -- Curseur et sélection
    Cursor = { fg = colors.bg, bg = colors.fg },
    CursorLine = { bg = colors.bg_highlight },
    CursorColumn = { bg = colors.bg_highlight },
    Visual = { bg = colors.surface1 },
    VisualNOS = { bg = colors.surface1 },

    -- Recherche
    Search = { fg = colors.bg, bg = colors.yellow },
    IncSearch = { fg = colors.bg, bg = colors.peach },
    CurSearch = { fg = colors.bg, bg = colors.red },

    -- Interface
    StatusLine = { fg = colors.fg, bg = colors.surface0 },
    StatusLineNC = { fg = colors.fg_dim, bg = colors.surface0 },
    TabLine = { fg = colors.fg_alt, bg = colors.surface0 },
    TabLineFill = { bg = colors.surface0 },
    TabLineSel = { fg = colors.fg, bg = colors.bg },

    -- Messages
    ErrorMsg = { fg = colors.red },
    WarningMsg = { fg = colors.yellow },
    ModeMsg = { fg = colors.green },
    MoreMsg = { fg = colors.blue },

    -- Popup menu
    Pmenu = { fg = colors.fg, bg = colors.surface0 },
    PmenuSel = { fg = colors.bg, bg = colors.blue },
    PmenuSbar = { bg = colors.surface1 },
    PmenuThumb = { bg = colors.overlay0 },

    -- Syntaxe
    Comment = { fg = colors.overlay1, italic = true },
    Constant = { fg = colors.peach },
    String = { fg = colors.green },
    Character = { fg = colors.green },
    Number = { fg = colors.peach },
    Boolean = { fg = colors.peach },
    Float = { fg = colors.peach },

    Identifier = { fg = colors.flamingo },
    Function = { fg = colors.blue },

    Statement = { fg = colors.mauve },
    Conditional = { fg = colors.red },
    Repeat = { fg = colors.red },
    Label = { fg = colors.sapphire },
    Operator = { fg = colors.sky },
    Keyword = { fg = colors.red },
    Exception = { fg = colors.peach },

    PreProc = { fg = colors.pink },
    Include = { fg = colors.pink },
    Define = { fg = colors.pink },
    Macro = { fg = colors.pink },
    PreCondit = { fg = colors.pink },

    Type = { fg = colors.yellow },
    StorageClass = { fg = colors.yellow },
    Structure = { fg = colors.yellow },
    Typedef = { fg = colors.yellow },

    Special = { fg = colors.sapphire },
    SpecialChar = { fg = colors.sapphire },
    Tag = { fg = colors.mauve },
    Delimiter = { fg = colors.overlay2 },
    SpecialComment = { fg = colors.sapphire },
    Debug = { fg = colors.peach },

    -- Diagnostic
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.sky },
    DiagnosticHint = { fg = colors.teal },
    DiagnosticUnnecessary = { fg = colors.overlay1 },

    -- Git
    DiffAdd = { fg = colors.green },
    DiffChange = { fg = colors.yellow },
    DiffDelete = { fg = colors.red },
    DiffText = { fg = colors.blue },

    -- Telescope (si utilisé)
    TelescopeBorder = { fg = colors.win_separator, bg = colors.bg },
    TelescopePromptBorder = { fg = colors.win_separator, bg = colors.bg },
    TelescopeResultsBorder = { fg = colors.win_separator, bg = colors.bg },
    TelescopePreviewBorder = { fg = colors.win_separator, bg = colors.bg },

    -- Nvim-tree (si utilisé)
    NvimTreeWinSeparator = { fg = colors.win_separator, bg = colors.bg },
    NvimTreeNormal = { fg = colors.fg, bg = colors.bg },
}

-- Appliquer les groupes de surbrillance
for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
end
