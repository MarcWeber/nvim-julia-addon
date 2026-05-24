-- vim.api.nvim_create_user_command("JuliaToQFFromTerminal", function() require'lua-terminal-to-qf':setup_julia_walkback() end, {})
vim.api.nvim_create_user_command("ZSHWithJuliaErrorWatchingOld", function() require'watched-terminal-process-finding-julia-errors':launch_watched_zsh() end, {})
vim.api.nvim_create_user_command("ZSHWithJuliaErrorWatching", function() require'watched-terminal-process-finding-julia-errors2':launch_julia_watcher() end, {})
