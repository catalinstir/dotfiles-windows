return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
  },
  init = function()
    -- Open nvim-tree instead of the empty start buffer when nvim is started without files
    if vim.fn.argc(-1) == 0 then
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          -- leave stdin (`cmd | nvim -`) and other non-empty start buffers alone
          if vim.api.nvim_buf_get_name(buf) ~= "" or vim.api.nvim_buf_line_count(buf) > 1 or vim.bo[buf].modified then
            return
          end
          vim.bo[buf].bufhidden = "wipe"
          require("nvim-tree.api").tree.open { current_window = true }
        end,
      })
    -- Load nvim-tree when nvim is opened with a directory
    elseif vim.fn.argc(-1) == 1 then
      local stat = vim.uv.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("lazy").load { plugins = { "nvim-tree.lua" } }
      end
    end
  end,
  config = function()
    -- Custom highlights for better visuals
    vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#8AADF4" })
    vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#F5A97F" })
    vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#A6DA95" })
    vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#ED8796" })
    vim.api.nvim_set_hl(0, "NvimTreeModifiedFile", { fg = "#EED49F" })

    require("nvim-tree").setup {
      actions = {
        expand_all = {
          exclude = { "node_modules", ".git", "target" },
        },
        file_popup = {
          open_win_config = {
            border = "rounded",
          },
        },
      },
      diagnostics = {
        debounce_delay = 50,
        enable = true,
        icons = {
          error = "󰅚",
          hint = "󰌶",
          info = "󰋽",
        },
      },
      filters = {
        custom = { "^.git$" },
        git_ignored = false,
      },
      modified = {
        enable = true,
      },
      reload_on_bufenter = true,
      renderer = {
        group_empty = true,
        highlight_bookmarks = "name",
        highlight_diagnostics = true,
        highlight_git = true,
        highlight_modified = "name",
        highlight_opened_files = "name",
        icons = {
          glyphs = {
            bookmark = "",
            default = "",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              deleted = "󰅖",
            },
            symlink = "",
          },
          show = {
            folder_arrow = false,
          },
          symlink_arrow = "  ",
        },
        indent_markers = {
          enable = true,
        },
        special_files = {
          "Cargo.toml",
          "Makefile",
          "README.md",
          "readme.md",
          "package.json",
          "CMakeLists.txt",
          ".gitignore",
        },
      },
      respect_buf_cwd = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = {
          enable = true,
        },
      },
      view = {
        number = true,
        relativenumber = true,
        signcolumn = "no",
        width = 35,
      },
    }
  end,
}
