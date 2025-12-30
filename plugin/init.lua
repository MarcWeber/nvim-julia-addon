-- vim.api.nvim_create_user_command("JuliaToQFFromTerminal", function() require'lua-terminal-to-qf':setup_julia_walkback() end, {})
vim.api.nvim_create_user_command("ZSHWithJuliaErrorWatching", function() require'watched-terminal-process-finding-isabelle-errors':launch_watched_zsh() end, {})
