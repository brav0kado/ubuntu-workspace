-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.wrap = false

-- This plugin version returns the install path with a trailing slash.
-- Keep that exact path in runtimepath as well as Neovim's standard site path.
local parser_site = vim.fn.stdpath("data") .. "/site/"
if not vim.tbl_contains(vim.api.nvim_list_runtime_paths(), parser_site) then
  vim.opt.runtimepath:prepend(parser_site)
end
-- Use the configured interactive shell for editor terminals.
if vim.fn.executable("zsh") == 1 then
  vim.opt.shell = vim.fn.exepath("zsh")
end
