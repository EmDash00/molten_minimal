require('quarto').setup{
  lspFeatures = {
    languages = { "python", "bash", "html" },
    chunks = "all",
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },

  codeRunner = {
    enabled = true,
    default_method = 'molten', -- 'molten' or 'slime'
  },

  keymap = {
    -- set whole section or individual keys to `false` to disable
    hover = "L",
    definition = "gd",
    type_definition = "gD",
    rename = "<leader>rn",
    format = "<leader>f",
    references = "gr",
    document_symbols = "gS",
  }
}

local runner = require("quarto.runner")

vim.keymap.set(
  "n", "<localleader>rc",
  runner.run_cell,
  { desc = "run cell", silent = true }
)

vim.keymap.set(
  "n", "<localleader>ra",
  runner.run_above,
  { desc = "run cell and above", silent = true }
)

vim.keymap.set(
  "n", "<localleader>rA",
  runner.run_all,
  { desc = "run all cells", silent = true }
)

vim.keymap.set(
  "n", "<localleader>rl",
  runner.run_line,
  { desc = "run line", silent = true }
)

vim.keymap.set(
  "v", "<localleader>r",
  runner.run_range,
  { desc = "run visual range", silent = true }
)

vim.keymap.set(
  "n", "<localleader>RA",
  function()
    runner.run_all(true)
  end,
  { desc = "run all cells of all languages", silent = true }
)
