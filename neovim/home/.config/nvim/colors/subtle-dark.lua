vim.cmd "highlight clear"
vim.cmd "syntax reset"
vim.o.background = "dark"
vim.g.colors_name = "subtle_dark"

local set = vim.api.nvim_set_hl

-- Utilitaires
local normal_fg = "#CCCCCC"
local normal_bg = "#000000"

-- Base
set(0, "Normal", { fg = normal_fg, bg = normal_bg })
set(0, "NormalNC", { fg = normal_fg, bg = normal_bg })
set(0, "CursorLine", { bg = "#1A1A1A" })
set(0, "Visual", { bg = "#2C313C" })
set(0, "LineNr", { fg = "#3A3A3A" })
set(0, "CursorLineNr", { fg = "#AAAAAA" })
set(0, "VertSplit", { fg = "#1A1A1A" })

-- Syntax
set(0, "Comment", { fg = "#5C6370", italic = true })
set(0, "Keyword", { fg = "#C678DD", italic = true })
set(0, "Function", { fg = "#61AFEF" })
set(0, "Identifier", { fg = "#E5C07B" })
set(0, "String", { fg = "#98C379" })
set(0, "Number", { fg = "#D19A66" })
set(0, "Constant", { fg = "#D19A66" })
set(0, "Type", { fg = "#56B6C2" })
set(0, "Statement", { fg = "#C678DD" })
set(0, "Operator", { fg = "#CCCCCC" })
set(0, "PreProc", { fg = "#61AFEF" })
set(0, "Special", { fg = "#E06C75" })

-- UI / Diagnostics
set(0, "Error", { fg = "#E06C75" })
set(0, "WarningMsg", { fg = "#D19A66" })
set(0, "Todo", { fg = "#61AFEF", bg = "#1A1A1A", bold = true })
set(0, "Pmenu", { fg = "#CCCCCC", bg = "#1A1A1A" })
set(0, "PmenuSel", { fg = "#000000", bg = "#61AFEF" })
set(0, "Search", { fg = "#000000", bg = "#98C379" })

-- LSP Diagnostics
set(0, "DiagnosticError", { fg = "#E06C75" })
set(0, "DiagnosticWarn", { fg = "#D19A66" })
set(0, "DiagnosticInfo", { fg = "#61AFEF" })
set(0, "DiagnosticHint", { fg = "#56B6C2" })

-- Treesitter (optionnel)
set(0, "@variable", { fg = "#E5C07B" })
set(0, "@function", { fg = "#61AFEF" })
set(0, "@keyword", { fg = "#C678DD", italic = true })
set(0, "@type", { fg = "#56B6C2" })
set(0, "@string", { fg = "#98C379" })
set(0, "@comment", { fg = "#5C6370", italic = true })
