-- Colorscheme "noir-contraste" pour Neovim
-- Un thème sombre avec fond noir et contrastes prononcés

-- Réinitialiser les couleurs existantes
vim.cmd "highlight clear"
if vim.fn.exists "syntax_on" then
    vim.cmd "syntax reset"
end

-- Définir le nom du colorscheme
vim.g.colors_name = "noir-contraste"

-- Palette de couleurs avec des contrastes plus prononcés
local colors = {
    -- Couleurs de base
    bg = "#000000",          -- Fond complètement noir
    fg = "#ffffff",          -- Texte principal (blanc pur)

    -- Grises pour les éléments secondaires
    gray1 = "#1a1a1a",       -- Gris très sombre
    gray2 = "#333333",       -- Gris sombre plus visible
    gray3 = "#555555",       -- Gris moyen plus contrasté
    gray4 = "#777777",       -- Gris clair
    gray5 = "#999999",       -- Gris plus clair

    -- Couleurs pour la syntaxe (tons plus vifs)
    blue = "#5aa3f0",        -- Bleu plus vif pour les keywords
    cyan = "#00d4ff",        -- Cyan éclatant pour les types
    green = "#7dd33f",       -- Vert plus vif pour les strings
    yellow = "#ffcc00",      -- Jaune plus éclatant pour les constantes
    orange = "#ff8c42",      -- Orange plus vif pour les nombres
    red = "#ff4757",         -- Rouge plus vif pour les erreurs
    purple = "#9c88ff",      -- Violet plus saturé pour les fonctions
    pink = "#ff6b9d",        -- Rose plus vif pour les variables

    -- Couleurs spéciales
    cursor = "#ffffff",      -- Curseur blanc
    selection = "#2d5aa0",   -- Sélection plus visible
    search = "#ffcc00",      -- Recherche jaune vif
    match_paren = "#ff6b9d", -- Parenthèses correspondantes rose vif

    -- Interface
    line_nr = "#777777",     -- Numéros de ligne plus visibles
    line_nr_current = "#999999", -- Numéro ligne actuelle plus contrasté
    status_line = "#222222", -- Barre de statut plus visible
    tab_line = "#111111",    -- Onglets
}

-- Fonction helper pour définir les highlights
local function highlight(group, opts)
    local cmd = "highlight " .. group
    if opts.fg then cmd = cmd .. " guifg=" .. opts.fg end
    if opts.bg then cmd = cmd .. " guibg=" .. opts.bg end
    if opts.style then cmd = cmd .. " gui=" .. opts.style end
    vim.cmd(cmd)
end

-- Couleurs de base de l'éditeur
highlight("Normal", { fg = colors.fg, bg = colors.bg })
highlight("NormalFloat", { fg = colors.fg, bg = colors.gray1 })
highlight("Cursor", { fg = colors.bg, bg = colors.cursor })
highlight("CursorLine", { bg = colors.gray1 })
highlight("CursorColumn", { bg = colors.gray1 })
highlight("ColorColumn", { bg = colors.gray1 })
highlight("LineNr", { fg = colors.line_nr })
highlight("CursorLineNr", { fg = colors.line_nr_current, style = "bold" })
highlight("SignColumn", { bg = colors.bg })

-- Sélection et recherche
highlight("Visual", { bg = colors.selection })
highlight("Search", { bg = colors.search, fg = colors.bg, style = "bold" })
highlight("IncSearch", { bg = colors.orange, fg = colors.bg, style = "bold" })
highlight("MatchParen", { fg = colors.match_paren, style = "bold,underline" })

-- Interface utilisateur
highlight("StatusLine", { fg = colors.fg, bg = colors.status_line })
highlight("StatusLineNC", { fg = colors.gray4, bg = colors.status_line })
highlight("TabLine", { fg = colors.gray4, bg = colors.tab_line })
highlight("TabLineSel", { fg = colors.fg, bg = colors.gray2 })
highlight("TabLineFill", { bg = colors.tab_line })
highlight("VertSplit", { fg = colors.gray2 })
highlight("Folded", { fg = colors.gray4, bg = colors.gray1 })
highlight("FoldColumn", { fg = colors.gray3, bg = colors.bg })

-- Messages et popups
highlight("Pmenu", { fg = colors.fg, bg = colors.gray2 })
highlight("PmenuSel", { fg = colors.bg, bg = colors.blue })
highlight("PmenuSbar", { bg = colors.gray3 })
highlight("PmenuThumb", { bg = colors.gray4 })
highlight("WildMenu", { fg = colors.bg, bg = colors.yellow })

-- Syntaxe générale
highlight("Comment", { fg = colors.gray4, style = "italic" })
highlight("Constant", { fg = colors.yellow, style = "bold" })
highlight("String", { fg = colors.green, style = "bold" })
highlight("Character", { fg = colors.green, style = "bold" })
highlight("Number", { fg = colors.orange, style = "bold" })
highlight("Boolean", { fg = colors.orange, style = "bold" })
highlight("Float", { fg = colors.orange, style = "bold" })

highlight("Identifier", { fg = colors.pink, style = "bold" })
highlight("Function", { fg = colors.purple, style = "bold" })

highlight("Statement", { fg = colors.blue, style = "bold" })
highlight("Conditional", { fg = colors.blue, style = "bold" })
highlight("Repeat", { fg = colors.blue, style = "bold" })
highlight("Label", { fg = colors.blue, style = "bold" })
highlight("Operator", { fg = colors.cyan, style = "bold" })
highlight("Keyword", { fg = colors.blue, style = "bold" })
highlight("Exception", { fg = colors.red, style = "bold" })

highlight("PreProc", { fg = colors.cyan, style = "bold" })
highlight("Include", { fg = colors.cyan, style = "bold" })
highlight("Define", { fg = colors.cyan, style = "bold" })
highlight("Macro", { fg = colors.cyan, style = "bold" })
highlight("PreCondit", { fg = colors.cyan, style = "bold" })

highlight("Type", { fg = colors.cyan, style = "bold" })
highlight("StorageClass", { fg = colors.blue, style = "bold" })
highlight("Structure", { fg = colors.cyan, style = "bold" })
highlight("Typedef", { fg = colors.cyan, style = "bold" })

highlight("Special", { fg = colors.orange, style = "bold" })
highlight("SpecialChar", { fg = colors.orange, style = "bold" })
highlight("Tag", { fg = colors.blue, style = "bold" })
highlight("Delimiter", { fg = colors.gray5 })
highlight("SpecialComment", { fg = colors.purple, style = "bold,italic" })
highlight("Debug", { fg = colors.red, style = "bold" })

-- Messages d'erreur et d'avertissement
highlight("Error", { fg = colors.red, style = "bold" })
highlight("ErrorMsg", { fg = colors.red, style = "bold" })
highlight("WarningMsg", { fg = colors.yellow, style = "bold" })
highlight("Todo", { fg = colors.yellow, bg = colors.gray2, style = "bold" })

-- Git (si plugin installé)
highlight("DiffAdd", { fg = colors.green, bg = colors.gray1 })
highlight("DiffChange", { fg = colors.yellow, bg = colors.gray1 })
highlight("DiffDelete", { fg = colors.red, bg = colors.gray1 })
highlight("DiffText", { fg = colors.cyan, bg = colors.gray2 })

-- LSP (Language Server Protocol)
highlight("DiagnosticError", { fg = colors.red })
highlight("DiagnosticWarn", { fg = colors.yellow })
highlight("DiagnosticInfo", { fg = colors.cyan })
highlight("DiagnosticHint", { fg = colors.purple })

-- Tree-sitter (syntaxe moderne)
highlight("@comment", { fg = colors.gray4, style = "italic" })
highlight("@string", { fg = colors.green })
highlight("@number", { fg = colors.orange })
highlight("@boolean", { fg = colors.orange })
highlight("@function", { fg = colors.purple, style = "bold" })
highlight("@keyword", { fg = colors.blue, style = "bold" })
highlight("@type", { fg = colors.cyan })
highlight("@variable", { fg = colors.pink })
highlight("@operator", { fg = colors.cyan })
highlight("@punctuation", { fg = colors.gray5 })

-- Spécifique aux langages
-- HTML
highlight("htmlTag", { fg = colors.blue })
highlight("htmlEndTag", { fg = colors.blue })
highlight("htmlTagName", { fg = colors.cyan })
highlight("htmlArg", { fg = colors.yellow })

-- CSS
highlight("cssClassName", { fg = colors.yellow })
highlight("cssIdentifier", { fg = colors.orange })
highlight("cssProp", { fg = colors.cyan })

-- JavaScript/TypeScript
highlight("jsFunction", { fg = colors.blue })
highlight("jsArrowFunction", { fg = colors.blue })
highlight("jsThis", { fg = colors.red })
highlight("jsSuper", { fg = colors.red })

-- Python
highlight("pythonSelf", { fg = colors.red })
highlight("pythonClass", { fg = colors.blue })
highlight("pythonFunction", { fg = colors.purple })

