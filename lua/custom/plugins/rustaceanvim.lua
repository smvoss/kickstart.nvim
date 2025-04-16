-- Rustaceanvim configuration
-- This file contains all the configuration for rustaceanvim

return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  ft = { 'rust' }, -- Load only when editing rust files
  config = function()
    -- Load rust-analyzer path from external config, fallback to default
    local rust_analyzer_cmd = { 'rust-analyzer' }
    local config_path = vim.fn.expand('~/.config/nvim-local/rust.lua')
    if vim.fn.filereadable(config_path) == 1 then
      local ok, cfg = pcall(dofile, config_path)
      if ok and cfg and cfg.rust_analyzer_path then
        rust_analyzer_cmd = { cfg.rust_analyzer_path }
      end
    end
    
    -- Set up rustaceanvim configuration
    vim.g.rustaceanvim = {
      server = {
        cmd = rust_analyzer_cmd,
        -- Increase timeout for initialization
        init_options = {
          -- Give rust-analyzer more time to start up
        },
        settings = {
          ['rust-analyzer'] = {
            -- Add some basic settings to help with initialization
            cargo = {
              allFeatures = true,
            },
          },
        },
        on_attach = function(client, bufnr)
          -- print("Rustaceanvim: LSP attached to buffer " .. bufnr)
          -- print("Rustaceanvim: Client name: " .. client.name)
        end,
        default_settings = {
          ['rust-analyzer'] = {
            -- Enable inlay hints by default in rust-analyzer settings
            -- inlayHints = {
              -- enable = true,
              -- You can customize which hints you want enabled:
              -- bindingModeHints = true,
              -- chainingHints = true,
              -- closingBraceHints = true,
              -- closureReturnTypeHints = true,
              -- implicitDrops = true,
              -- lifetimeElisionHints = { enable = true, useParameterNames = true },
              -- parameterHints = true,
              -- reborrowHints = true,
              -- typeHints = true,
            -- },
            -- Add any additional rust-analyzer settings here
            -- For example:
            -- checkOnSave = {
            --   command = "clippy",
            -- },
          },
        },
      },
      -- DAP configuration
      dap = {
        -- adapter = {...} -- You can add custom adapter configuration here
      },
    }
    
    -- Create an autocommand to enable inlay hints when a Rust file is opened
    local rust_inlay_hints = vim.api.nvim_create_augroup("RustInlayHints", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      group = rust_inlay_hints,
      callback = function(event)
        -- Enable inlay hints if they're available
        -- This requires Neovim 0.10.0+
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
      end,
    })
  end,
  dependencies = {
    'mfussenegger/nvim-dap', -- Required for debugging support
  },
}
