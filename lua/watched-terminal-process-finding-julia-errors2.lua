local manager = require('watched-terminal')

local M = {}

--- Launches a Julia REPL session with automatic Quickfix updates 
--- by watching the terminal output for errors.
--- @param opts table? Configuration options
function M.launch_julia_watcher(opts)
  opts = opts or {}
  
  -- The command wraps julia in a shell or calls it directly.
  -- Using 'julia' directly is usually preferred unless you need specific zsh aliases.
  local cmd = opts.cmd or "julia"

  return manager.spawn({
    name = opts.name or "Julia-Watcher",
    cmd = cmd,
    instance_key = "julia_repl",

    triggers = {
      {
        -- The "pattern" identifies lines that should trigger a Quickfix update.
        -- In the original, the 'julia>' prompt signaled the end of an error block.
        pattern = "julia>",

        -- The "flush_pattern" clears the internal buffer when matched.
        -- We clear when we see the official release header to avoid stale data.
        flush_pattern = "Official https://julialang.org release",

        -- Setting the errorformat for Julia.
        efm = function()
          -- Set the internal errorformat before returning the string 
          -- if the manager relies on vim.opt.errorformat
          vim.cmd('Errorformat julia') 
          return vim.bo.errorformat
        end,

        title = "Julia Watcher",
      }
    }
  })
end

return M
