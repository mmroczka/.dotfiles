-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
  -- VSCode-only config
  require("config.vscode")
else
  -- Full-blown standalone Neovim config
  require("config.lazy")
end
