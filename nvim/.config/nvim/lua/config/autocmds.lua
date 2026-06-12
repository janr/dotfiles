-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function inspect_pos_scratch()
  local items = vim.inspect_pos()
  local lines = {}

  local function add(line)
    lines[#lines + 1] = line
  end

  local function add_items(title, values, format)
    if #values == 0 then
      return
    end

    add(title)
    for _, value in ipairs(values) do
      add(format(value))
    end
    add("")
  end

  add_items("Treesitter", items.treesitter, function(item)
    local link = item.hl_group ~= item.hl_group_link and (" links to " .. item.hl_group_link) or ""
    return ("  - %s%s %s"):format(item.hl_group, link, item.lang)
  end)

  add_items("Semantic Tokens", items.semantic_tokens, function(item)
    local opts = item.opts
    local link = opts.hl_group ~= opts.hl_group_link and (" links to " .. opts.hl_group_link) or ""
    return ("  - %s%s priority: %s"):format(opts.hl_group, link, opts.priority)
  end)

  add_items("Syntax", items.syntax, function(item)
    local link = item.hl_group ~= item.hl_group_link and (" links to " .. item.hl_group_link) or ""
    return ("  - %s%s"):format(item.hl_group, link)
  end)

  add_items("Extmarks", items.extmarks, function(item)
    if item.opts.hl_group then
      local link = item.opts.hl_group ~= item.opts.hl_group_link and (" links to " .. item.opts.hl_group_link) or ""
      return ("  - %s%s %s"):format(item.opts.hl_group, link, item.ns)
    end

    return ("  - %s"):format(item.ns)
  end)

  if #lines == 0 then
    add(("No items found at position %s,%s in buffer %s"):format(items.row, items.col, items.buffer))
  elseif lines[#lines] == "" then
    table.remove(lines)
  end

  vim.cmd("botright 12new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "Inspect"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command("Inspect", function(cmd)
  if cmd.bang then
    vim.print(vim.inspect_pos())
  else
    inspect_pos_scratch()
  end
end, { desc = "Inspect highlights and extmarks at the cursor", bang = true })
