return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup({
      copy_sync = {
        enable = false,
      },
      navigation = {
        enable_default_keybindings = true,
        cycle_navigation = false,
      },
      resize = {
        enable_default_keybindings = true,
        resize_step_x = 50,
        resize_step_y = 10,
      },
    })
  end,
}
