return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "go", "gomod", "gosum", "gowork", "ruby", "php", "php_only",
        "sql", "css", "scss", "dockerfile", "make", "c", "cpp", "rust",
        "python", "bash", "lua", "json", "yaml", "toml", "html",
        "javascript", "typescript", "tsx", "markdown", "markdown_inline",
      },
    },
  },
}
