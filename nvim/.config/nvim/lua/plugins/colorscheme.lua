return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
  },
  { "mhartington/oceanic-next" },
  { "Everblush/nvim", name = "everblush" },
  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    name = "arctic",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "arctic",
    },
  },
}
