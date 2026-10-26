-- Delete buffers but keep their windows (plain :bd would leave only nvim-tree open).
-- Bufferline's close commands call it too.
return {
  "nvim-mini/mini.bufremove",
  opts = {},
  keys = {
    {
      "<leader>bd",
      function()
        require("mini.bufremove").delete()
      end,
      desc = "Delete buffer",
    },
  },
}
