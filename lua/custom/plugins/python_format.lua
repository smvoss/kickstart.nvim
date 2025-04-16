-- Python formatting configuration for conform.nvim
-- Configures isort and black to use Poetry or local virtualenv if available

return {
  "stevearc/conform.nvim",
  -- This plugin is already loaded by kickstart, so we're just extending its configuration
  opts = function(_, opts)
    -- Helper function to find executables in virtualenv
    local function find_venv_executable(cmd)
      -- Check for Poetry virtualenv
      local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info -p 2>/dev/null"))
      if poetry_venv ~= "" then
        local poetry_cmd = poetry_venv .. "/bin/" .. cmd
        if vim.fn.executable(poetry_cmd) == 1 then
          return poetry_cmd
        end
      end
      
      -- Check for .venv directory in project root
      local venv_path = vim.fn.getcwd() .. "/.venv"
      if vim.fn.isdirectory(venv_path) == 1 then
        local venv_cmd = venv_path .. "/bin/" .. cmd
        if vim.fn.executable(venv_cmd) == 1 then
          return venv_cmd
        end
      end
      
      -- Fall back to system executable
      return cmd
    end
    
    -- Configure formatters to use virtualenv if available
    opts.formatters = opts.formatters or {}
    
    -- Configure black
    opts.formatters.black = {
      command = find_venv_executable("black"),
      args = { "--quiet", "-" },
      cwd = require("conform.util").root_file({ "pyproject.toml", "setup.py", "setup.cfg", ".git" }),
    }
    
    -- Configure isort
    opts.formatters.isort = {
      command = find_venv_executable("isort"),
      args = { "--profile", "black", "--quiet", "-" },
      cwd = require("conform.util").root_file({ "pyproject.toml", "setup.py", "setup.cfg", ".git" }),
    }
    
    -- Ensure Python has the formatters configured
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.python = opts.formatters_by_ft.python or {}
    
    -- If Python formatters aren't already configured, set them up
    if not vim.tbl_contains(opts.formatters_by_ft.python, "isort") and 
       not vim.tbl_contains(opts.formatters_by_ft.python, "black") then
      opts.formatters_by_ft.python = { "isort", "black" }
    end
    
    -- Log that the Python formatting is configured
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function()
        -- Only notify once per session
        if not vim.g.python_format_notified then
          vim.notify("Python formatting configured with virtualenv support", vim.log.levels.INFO)
          vim.g.python_format_notified = true
        end
      end,
      once = true,
    })
    
    return opts
  end,
}
