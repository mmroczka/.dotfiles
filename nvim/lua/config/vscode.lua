local vscode = require("vscode")
-- vscode-harpoon.addEditor
vim.g.mapleader = " "

local function toggle_terminal()
  local ok, err = pcall(function()
    vim.fn.VSCodeCall("workbench.action.terminal.toggleTerminal")
  end)
  if not ok then
    print("Error toggling terminal:", err)
  end
end

-- Map leader+t to toggle terminal in editor context
vim.keymap.set("n", "<leader>t", toggle_terminal, {
  silent = true,
  desc = "Toggle terminal",
})

-- Map leader+t to toggle terminal in explorer context
vim.keymap.set("n", "<leader>t", toggle_terminal, {
  silent = true,
  desc = "Toggle terminal",
  buffer = true,
  nowait = true,
})
-- vim.keymap.set({ "n", "x" }, "<leader>m", function()
--   vscode.action("vscode-harpoon.editorQuickPick")
-- end)
