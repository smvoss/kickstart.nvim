-- Local plugins loader
-- Loads additional plugins from ~/.config/nvim-local/plugins/ if they exist
-- This allows machine-specific or work-specific plugins outside the main repo

local local_path = vim.fn.expand('~/.config/nvim-local')
local local_plugins_path = local_path .. '/plugins'

-- Add nvim-local to lua package path for imports
if vim.fn.isdirectory(local_path) == 1 then
  package.path = local_path .. '/?.lua;' .. package.path
  vim.opt.rtp:prepend(local_path)
  
  -- Load standalone configs (non-plugin lua files)
  local barium_path = local_path .. '/barium.lua'
  if vim.fn.filereadable(barium_path) == 1 then
    vim.defer_fn(function() dofile(barium_path) end, 100)
  end
end

-- Manually load plugin specs from local plugins directory
local specs = {}
if vim.fn.isdirectory(local_plugins_path) == 1 then
  for _, file in ipairs(vim.fn.glob(local_plugins_path .. '/*.lua', false, true)) do
    local name = vim.fn.fnamemodify(file, ':t:r')
    if name ~= 'init' then
      local ok, spec = pcall(dofile, file)
      if ok and spec then
        for _, s in ipairs(type(spec[1]) == 'table' and spec or {spec}) do
          table.insert(specs, s)
        end
      end
    end
  end
end
return specs
