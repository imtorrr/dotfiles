return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true,
        ignored = true,
        exclude = {
          "**/.git/*",
        },
        sources = {
          explorer = {
            layout = {
              layout = {
                position = "left",
              },
            },
          },
        },
      },
    },
  },
}
