Julia Neovim REPL error quickfix support
=========================================
depnedencies:
https://github.com/MarcWeber/vim-addon-errorformats
or supply your own error format like this:

let efm=  @ %f:%l,   @ %f:%l

Implementation 1:
=================
lua/watched-terminal-process-finding-isabelle-errors.lua

Works only on Linux/OSX because it creates a fifo file to pipe stdout/err of
zsh also to the pipe which is then read by Neovim's libuv loop.
If it finds julia> prompt it feeds the output to quickfix which then 
finds error locations

Usage like this:
================
:ZSHWithJuliaErrorWatching
A terminal should open, then type julia .. then load your code.
Quickfix should be populated automatically

Implementation 2:
=================
lua/lua-terminal-to-qf.lua This is an attempt which should also work on Windows
by watching the Vim terminal buffer instead. The problem is if you don't focus
on the buffer the event doesn't get triggered.
