-- ========== Neovim Base Settings ==========
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

vim.opt.number = true         -- Shows absolute line number on the current line
vim.opt.relativenumber = true -- Shows relative numbers on all other lines

vim.o.background = "dark"
vim.o.laststatus = 2
vim.o.statusline = "%m%r%h%w [%{mode()}] %f %y %=%l:%c"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", { silent = false })

-- ========== lazy.nvim Bootstrap ==========
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
                "git", "clone", "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git", lazypath
        })
end
vim.opt.rtp:prepend(lazypath)

-- ========== Plugin Setup ==========
require("lazy").setup({
        -- In your plugins table
        {
                "akinsho/toggleterm.nvim",
                version = "*",
                config = true
        },

        {
                "windwp/nvim-autopairs",
                event = "InsertEnter",
                config = function()
                        require("nvim-autopairs").setup({})
                end,
        },

        {
                'nvim-telescope/telescope.nvim',
                tag = '0.1.4',
                dependencies = { 'nvim-lua/plenary.nvim' },
                cmd = "Telescope",
                keys = {
                        { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
                        { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live Grep" },
                        { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Find Buffers" },
                        { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "Help Tags" },
                },
                config = function()
                        require('telescope').setup({})
                end,
        },

        -- File explorer
        {
                "nvim-tree/nvim-tree.lua",
                dependencies = { "nvim-tree/nvim-web-devicons" },
                config = function()
                        require("nvim-tree").setup({
                                update_focused_file = {
                                        enable = true,
                                        update_root = true,
                                        ignore_list = {},
                                },
                        }
                        )
                        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
                end,
        },

        -- Statusline
        {
                "nvim-lualine/lualine.nvim",
                dependencies = { "nvim-tree/nvim-web-devicons" },
                config = function()
                        require("lualine").setup({
                                options = { theme = "auto" }
                        })
                end,
        },

        -- Treesitter (syntax)
        {
                "nvim-treesitter/nvim-treesitter",
                build = ":TSUpdate",
                config = function()
                        require("nvim-treesitter.configs").setup({
                                ensure_installed = { "go", "lua" },
                                highlight = { enable = true },
                                indent = { enable = true },
                        })
                end,
        },

        -- Color Theme: VS Code Dark Modern
        {
                "gmr458/vscode_modern_theme.nvim",
                lazy = false,
                priority = 1000,
                config = function()
                        require("vscode_modern").setup({
                                cursorline = true,
                                transparent_background = false,
                                nvim_tree_darker = true,
                                lualine_bold = true,
                        })

                        vim.cmd.colorscheme("vscode_modern")
                end,
        },

        -- LSP + Mason + gopls config
        {
                "VonHeikemen/lsp-zero.nvim",
                branch = "v3.x",
                dependencies = {
                        "neovim/nvim-lspconfig",
                        "williamboman/mason.nvim",
                        "williamboman/mason-lspconfig.nvim",
                        "hrsh7th/nvim-cmp",
                        "hrsh7th/cmp-nvim-lsp",
                        "L3MON4D3/LuaSnip",
                },
                config = function()
                        local lsp = require("lsp-zero").preset({})

                        lsp.on_attach(function(_, bufnr)
                                lsp.default_keymaps({ buffer = bufnr })
                        end)

                        lsp.setup()

                        require("mason").setup()
                        require("mason-lspconfig").setup({
                                ensure_installed = { "gopls", "lua_ls", "tsserver" },
                                handlers = {
                                        gopls = function()
                                                local capabilities = vim.lsp.protocol.make_client_capabilities()
                                                capabilities.textDocument.semanticTokens = {
                                                        dynamicRegistration = false,
                                                        requests = {
                                                                range = true,
                                                                full = true,
                                                        },
                                                        formats = { "relative" },
                                                }

                                                require("lspconfig").gopls.setup({
                                                        capabilities = capabilities,
                                                        settings = {
                                                                gopls = {
                                                                        codelenses = {
                                                                                generate = true, -- for 'go generate'
                                                                                gc_details = true,
                                                                                test = true,
                                                                                tidy = true,
                                                                                upgrade_dependency = true,
                                                                                vendor = true,
                                                                        },
                                                                        gofumpt = true,
                                                                        staticcheck = true,
                                                                        analyses = {
                                                                                unusedparams = true,
                                                                                unusedwrite = true,
                                                                        },
                                                                        usePlaceholders = true,
                                                                        ["formatting.formatTool"] = "goimports",
                                                                },
                                                        },
                                                })
                                        end,

                                        lua_ls = function()
                                                require("lspconfig").lua_ls.setup({})
                                        end,

                                        pyright = function()
                                                require("lspconfig").pyright.setup({})
                                        end,

                                        tsserver = function()
                                                require("lspconfig").tsserver.setup({})
                                        end,
                                },
                        })
                end,
        },

        -- Completion Engine
        {
                "hrsh7th/nvim-cmp",
                dependencies = {
                        "hrsh7th/cmp-nvim-lsp",
                        "L3MON4D3/LuaSnip",
                },
                config = function()
                        local cmp = require("cmp")
                        cmp.setup({
                                snippet = {
                                        expand = function(args)
                                                require("luasnip").lsp_expand(args.body)
                                        end,
                                },
                                mapping = cmp.mapping.preset.insert({
                                        ["<Tab>"] = cmp.mapping.select_next_item(),
                                        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                                        ["<C-Space>"] = cmp.mapping.complete(),
                                }),
                                sources = {
                                        { name = "nvim_lsp" },
                                        { name = "luasnip" },
                                },
                        })
                end,
        },
        {
                'f-person/git-blame.nvim',
                config = function()
                        vim.g.gitblame_enabled = 1
                        -- Optional: customize the blame message format
                        vim.g.gitblame_message_template = '<author> • <date> • <summary>'
                        vim.g.gitblame_date_format = '%r' -- relative date like "2 weeks ago"
                end,
                event = { "BufReadPost" },
        },

        {
                'numToStr/Comment.nvim',
                lazy = false,
                config = function()
                        require('Comment').setup()
                end,
        },


})


vim.diagnostic.config({
        virtual_text = {
                spacing = 2,
                -- prefix = "",  -- small bullet
        },
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
})

local signs = {
        Error = " ",
        Warn  = " ",
        Hint  = " ",
        Info  = " ",
}
for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.o.updatetime = 500
vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus = false })
]])





-- Optional: Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
                vim.lsp.buf.format({
                        async = false,
                        bufnr = args.buf,
                        timeout_ms = 2000,
                })
        end,
})
vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
                if vim.bo.modified then
                        local choice = vim.fn.input("You have unsaved changes. Save before closing? (y/n): ")
                        if choice:lower() == "y" then
                                vim.cmd("write")
                        end
                end
        end,
})


-- Next buffer with Tab
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })

-- Previous buffer with Shift+Tab
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>t", "<cmd>Telescope oldfiles<CR>", { desc = "Open Recent File" })
vim.keymap.set("n", "<C-s>", "<Esc>:w<CR>a", { silent = true, desc = "Save in insert mode" })

vim.keymap.set("n", 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set("n", 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
vim.keymap.set("n", 'gr', vim.lsp.buf.references, { noremap = true, silent = true })
vim.keymap.set("n", '<C-s>', ":w<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>y", ":%y+<CR>", { desc = "Copy entire file to clipboard" })
-- Move current line up or down (Normal mode)
-- NORMAL mode
vim.keymap.set("n", "<leader>j", ":m .+1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("n", "<leader>k", ":m .-2<CR>==", { silent = true, desc = "Move line up" })

-- VISUAL mode
vim.keymap.set("v", "<leader>j", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("v", "<leader>k", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

-- Move selected lines up or down (Visual mode)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })


vim.keymap.set({ "i", "v" }, "jj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("t", "jj", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { silent = true })
vim.keymap.set({ "n", "i" }, "gi", vim.lsp.buf.implementation, { noremap = true, silent = true })
vim.keymap.set("i", "<C-k>", function()
        vim.lsp.buf.hover()
end, { desc = "LSP Hover in insert mode" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo in insert mode" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { silent = true, desc = "Save in insert mode" })

vim.keymap.set("n", "<leader>a", ":%y+<CR>", { desc = "Copy Entire File" })
vim.keymap.set("n", "<leader>aa", "gg0vG$y", { desc = "Select and copy all" })
vim.keymap.set("n", "<leader>d", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>gt", function()
        local file = vim.fn.expand("<cfile>")
        vim.cmd("tabedit " .. file)
end, { desc = "Open file under cursor in new tab" })
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "$", "$", { noremap = true })
vim.api.nvim_set_hl(0, "SpellBad", { underline = true, sp = "#0000FF" })
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        callback = function()
                vim.lsp.codelens.refresh()
        end,
})
vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client.supports_method("textDocument/codeLens") then
                        vim.lsp.codelens.refresh()
                end
        end,
})


vim.keymap.set("n", "9", "$", { noremap = true, silent = true })
