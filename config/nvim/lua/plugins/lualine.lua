return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local function get_venv_name()
      local venv_path = os.getenv("VIRTUAL_ENV")
      if not venv_path then
        return ""
      end

      -- Extracts the project name (parent dir of .venv)
      -- e.g., /home/project/.venv -> project
      local name = venv_path:match("([^/]+)/[^/]+$")
      return name and (" " .. name) or ""
    end

    -- Insert into the statusline
    -- section_x is usually a good spot for info like this
    table.insert(opts.sections.lualine_x, 1, {
      get_venv_name,
      color = { fg = "#38bdf8" }, -- Adjust color to your liking
    })
  end,
}
