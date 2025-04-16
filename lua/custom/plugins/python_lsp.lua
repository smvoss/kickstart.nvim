-- Python LSP configuration
-- Configures pyright to properly handle imports in Python projects

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Get the existing pyright configuration or create a new one
    local servers = opts.servers or {}
    local pyright_opts = servers.pyright or {}
    
    -- Helper function to find Python executable in virtualenv
    local function find_python_path()
      -- Check for Poetry virtualenv
      local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info -p 2>/dev/null"))
      if poetry_venv ~= "" then
        local poetry_python = poetry_venv .. "/bin/python"
        if vim.fn.executable(poetry_python) == 1 then
          return poetry_python
        end
      end
      
      -- Check for .venv directory in project root
      local venv_path = vim.fn.getcwd() .. "/.venv"
      if vim.fn.isdirectory(venv_path) == 1 then
        local venv_python = venv_path .. "/bin/python"
        if vim.fn.executable(venv_python) == 1 then
          return venv_python
        end
      end
      
      -- Fall back to system Python
      return "python"
    end
    
    -- Configure pyright with improved import resolution
    pyright_opts.settings = vim.tbl_deep_extend("force", pyright_opts.settings or {}, {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          -- Enable import resolution
          extraPaths = {},
        },
        pythonPath = find_python_path(),
      },
    })
    
    -- Create a function to update Python path when changing directories
    local function update_python_path()
      local client = vim.lsp.get_active_clients({ name = "pyright" })[1]
      if client then
        local python_path = find_python_path()
        client.config.settings.python.pythonPath = python_path
        client.notify("workspace/didChangeConfiguration", {
          settings = client.config.settings
        })
        vim.notify("Updated Python path to: " .. python_path, vim.log.levels.INFO)
      end
    end
    
    -- Create autocmd to update Python path when changing directories
    vim.api.nvim_create_autocmd("DirChanged", {
      pattern = "*",
      callback = function()
        update_python_path()
      end,
      desc = "Update Python path when changing directories",
    })
    
    -- Create autocmd to update Python path when opening Python files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function()
        -- Only run once per session
        if not vim.g.python_lsp_setup_done then
          vim.defer_fn(function()
            update_python_path()
            vim.g.python_lsp_setup_done = true
          end, 1000)
        end
      end,
      once = true,
    })
    
    -- Update the servers table with our enhanced pyright config
    servers.pyright = pyright_opts
    opts.servers = servers
    
    return opts
  end,
}
