local lsp_status = require('lsp-status')
local nvim_lsp = require('lspconfig')

lsp_status.register_progress()

local attach_hook = function(client)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require'completion'.on_attach(client)
    require'lsp-status'.on_attach(client)

    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lS', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lk', '<cmd>lua vim.lsp.buf.help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lF', '<cmd>lua vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ld', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>le', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gW', '<cmd>lua vim.lsp.buf.workplace_symbol()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[c', ':<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']c', ':<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lt', "<cmd>lua require'lsp_extensions'.inlay_hints()<CR>", opts)
end

-- add pylance support
-- technically against pylance license lol
-- based off of https://github.com/neovim/nvim-lspconfig/pull/303
local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

configs["pylance"] = {
    default_config = {
        cmd = {"pylance-language-server"}; -- requires aur/pylance-language-server
        filetypes = {"python"};
        root_dir = util.root_pattern(".git", "setup.py",  "setup.cfg", "pyproject.toml", "requirements.txt");
        settings = {
            python = { analysis = {
                autoSearchPaths= true;
                useLibraryCodeForTypes = true;
                typeCheckingMode = "basic";
            }};
        };
        -- The following before_init function can be removed once https://github.com/neovim/neovim/pull/12638 is merged
        before_init = function(initialize_params)
            initialize_params['workspaceFolders'] = {{
                name = 'workspace',
                uri = initialize_params['rootUri']
            }}
        end
    };
    docs = {
        description = [[
        https://github.com/microsoft/pylance-release
        `pylance`, a static type checker and language server for python
        ]];
    };
}
-- end pylance

-- add dhall
configs["dhall"] = {
    default_config = {
        cmd = {"dhall-lsp-server"};
        filetypes = {"dhall"};
        root_dir = util.path.dirname;
    };
}
--

local default_config_servers = {
    'clangd',
    'clojure_lsp',
    'cmake',
    'cssls',
    'dhall',
    'hls',
    'html',
    -- 'jdtls',
    'jsonls',
    'metals',
    'pylance',
    'rust_analyzer',
    'sumneko_lua',
    'texlab',
    'tsserver',
    'vimls',
    'yamlls',
}

for _, lsp in ipairs(default_config_servers) do
    nvim_lsp[lsp].setup {
        on_attach = attach_hook,
        capabilities=lsp_status.capabilities,
    }
end
