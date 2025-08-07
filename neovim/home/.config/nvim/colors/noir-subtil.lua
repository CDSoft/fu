-- Colorscheme "noir-subtil" pour Neovim
-- Un thème sombre avec fond noir et contrastes subtils

-- Réinitialiser les couleurs existantes
vim.cmd "highlight clear"
if vim.fn.exists "syntax_on" then
    vim.cmd "syntax reset"
end

-- Définir le nom du colorscheme
vim.g.colors_name = "noir-subtil"

-- Palette de couleurs avec des tons subtils
local colors = {
    -- Couleurs de base
    bg = "#000000",          -- Fond complètement noir
    fg = "#e6e6e6",          -- Texte principal (gris très clair)

    -- Grises pour les éléments secondaires
    gray1 = "#1a1a1a",       -- Gris très sombre
    gray2 = "#2a2a2a",       -- Gris sombre
    gray3 = "#444444",       -- Gris moyen
    gray4 = "#666666",       -- Gris clair
    gray5 = "#888888",       -- Gris plus clair

    -- Couleurs pour la syntaxe (tons subtils)
    blue = "#7aa2f7",        -- Bleu doux pour les keywords
    cyan = "#7dcfff",        -- Cyan pour les types
    green = "#9ece6a",       -- Vert doux pour les strings
    yellow = "#e0af68",      -- Jaune doux pour les constantes
    orange = "#ff9e64",      -- Orange subtil pour les nombres
    red = "#f7768e",         -- Rouge doux pour les erreurs
    purple = "#bb9af7",      -- Violet pour les fonctions
    pink = "#c0caf5",        -- Rose pâle pour les variables

    -- Couleurs spéciales
    cursor = "#ffffff",      -- Curseur blanc
    selection = "#2d3748",   -- Sélection
    search = "#4a5568",      -- Recherche
    match_paren = "#744da9", -- Parenthèses correspondantes

    -- Interface
    line_nr = "#3a3a3a",     -- Numéros de ligne
    line_nr_current = "#666666", -- Numéro ligne actuelle
    status_line = "#1a1a1a", -- Barre de statut
    tab_line = "#0f0f0f",    -- Onglets
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
highlight("Search", { bg = colors.search, fg = colors.fg })
highlight("IncSearch", { bg = colors.yellow, fg = colors.bg })
highlight("MatchParen", { fg = colors.match_paren, style = "bold" })

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
highlight("Constant", { fg = colors.yellow })
highlight("String", { fg = colors.green })
highlight("Character", { fg = colors.green })
highlight("Number", { fg = colors.orange })
highlight("Boolean", { fg = colors.orange })
highlight("Float", { fg = colors.orange })

highlight("Identifier", { fg = colors.pink })
highlight("Function", { fg = colors.purple, style = "bold" })

highlight("Statement", { fg = colors.blue, style = "bold" })
highlight("Conditional", { fg = colors.blue })
highlight("Repeat", { fg = colors.blue })
highlight("Label", { fg = colors.blue })
highlight("Operator", { fg = colors.cyan })
highlight("Keyword", { fg = colors.blue, style = "bold" })
highlight("Exception", { fg = colors.red })

highlight("PreProc", { fg = colors.cyan })
highlight("Include", { fg = colors.cyan })
highlight("Define", { fg = colors.cyan })
highlight("Macro", { fg = colors.cyan })
highlight("PreCondit", { fg = colors.cyan })

highlight("Type", { fg = colors.cyan, style = "bold" })
highlight("StorageClass", { fg = colors.blue })
highlight("Structure", { fg = colors.cyan })
highlight("Typedef", { fg = colors.cyan })

highlight("Special", { fg = colors.orange })
highlight("SpecialChar", { fg = colors.orange })
highlight("Tag", { fg = colors.blue })
highlight("Delimiter", { fg = colors.gray5 })
highlight("SpecialComment", { fg = colors.purple, style = "italic" })
highlight("Debug", { fg = colors.red })

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

