-- Terminal configuration for Neovim
-- This file contains all terminal-related settings and keymaps

return {
  -- Terminal plugin: toggleterm.nvim with all terminal configuration
  {
    'akinsho/toggleterm.nvim', 
    version = "*", 
    lazy = false, -- Make sure the plugin loads at startup
    config = function()
      -- Configure the toggleterm plugin
      require("toggleterm").setup {
        open_mapping = [[<c-\>]],
        size = 20,
        -- Add shade to distinguish terminal from regular buffers
        shade_terminals = true,
        -- Add a border to make terminals more distinct
        float_opts = {
          border = "curved",
        },
        -- Set custom highlights for terminals
        highlights = {
        },
      }

      -- Exit terminal mode with Escape key
      vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

      -- Toggle terminal size between 20 and 100 lines
      vim.keymap.set({'t', 'n'}, '<C-n>',
        function()
          local window = vim.api.nvim_get_current_win()
          local height = vim.api.nvim_win_get_height(window)

          if height ~= 20 then
            height = 20
          else
            height = 100
          end

          vim.api.nvim_win_set_height(window, height)
        end
      )

      -- Set global terminal height
      vim.g.terminal_height = 20

      -- Create named terminal instances
      local Terminal = require('toggleterm.terminal').Terminal

      -- Primary terminal - toggled with Ctrl+\
      local term1 = Terminal:new({
        count = 1,
        direction = "horizontal",
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      -- Secondary terminal - toggled with Alt+\
      local term2 = Terminal:new({
        count = 2,
        direction = "horizontal",
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      -- Function to toggle primary terminal (Ctrl+\)
      function _G.toggle_terminal_1()
        term1:toggle()
      end

      -- Function to toggle secondary terminal (Alt+\)
      function _G.toggle_terminal_2()
        term2:toggle()
      end

      -- Map Alt+\ to toggle the second terminal
      vim.keymap.set({'n', 't'}, '<A-\\>', '<cmd>lua toggle_terminal_2()<CR>', 
        {noremap = true, silent = true, desc = 'Toggle secondary terminal'})

      -- Remap Ctrl+\ to use our specific function for the first terminal
      vim.keymap.set({'n', 't'}, '<C-\\>', '<cmd>lua toggle_terminal_1()<CR>', 
        {noremap = true, silent = true, desc = 'Toggle primary terminal'})

    end
  }
}
