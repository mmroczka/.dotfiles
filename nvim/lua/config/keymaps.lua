-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- tmux/nvim seamless navigation (overrides LazyVim's <C-w> defaults)
vim.keymap.set("n", "<C-h>", [[<cmd>lua require('tmux').move_left()<cr>]], { desc = "Move left (tmux/nvim)" })
vim.keymap.set("n", "<C-j>", [[<cmd>lua require('tmux').move_bottom()<cr>]], { desc = "Move down (tmux/nvim)" })
vim.keymap.set("n", "<C-k>", [[<cmd>lua require('tmux').move_top()<cr>]], { desc = "Move up (tmux/nvim)" })
vim.keymap.set("n", "<C-l>", [[<cmd>lua require('tmux').move_right()<cr>]], { desc = "Move right (tmux/nvim)" })
