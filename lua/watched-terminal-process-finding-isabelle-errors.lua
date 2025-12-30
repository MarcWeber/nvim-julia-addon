local M = {}

local function iterator_to_array(...)
  local arr = {}
  for v in ... do
    table.insert(arr, v)
  end
  return arr
end




function M.launch_watched_zsh()
  local pipe_path = "/tmp/julia_qf_" .. os.time()
  vim.fn.system("mkfifo " .. pipe_path)

  -- 1. Open with O_NONBLOCK (represented by bitwise flags)
  -- 0x0000 is read-only, but we need the non-blocking flag to prevent the hang
  -- On macOS/BSD, O_NONBLOCK is usually 0x0004
  local uv = vim.loop or vim.uv
  uv.fs_open(pipe_path, "r", 438, function(err, fd)
    if err or not fd then 
      return vim.schedule(function() print("Pipe Error: " .. (err or "no fd")) end)
    end
    local read_handle = uv.new_pipe(false)
    read_handle:open(fd)
    local current_bucket = ""
    read_handle:read_start(function(read_err, data)
      if read_err or not data then return end
      current_bucket = current_bucket .. data
      if current_bucket:find("Official https://julialang.org release") then
        current_bucket = ""
      elseif data:find("julia>") then
        local clean = current_bucket:gsub("\x1b%[[0-9;]*%a", "")
        local items = iterator_to_array(string.gmatch(clean, "[^\n\r]+"))
        if #items > 2 then
          local l = items
          vim.schedule(function()
            vim.cmd('Errorformat julia')
            vim.fn.setqflist({}, ' ', { title = "Julia Watcher", lines = l })
          end)
          current_bucket = ""
        end
      end
    end)
    _G._julia_read_handle = read_handle
  end)

  -- 2. Launch Terminal
  -- Using 'zsh -i' can help ensure the shell environment is fully loaded
  local zsh_cmd = string.format("zsh -i -c 'exec zsh |& tee %s'", pipe_path)
  
  vim.cmd("split")
  vim.fn.termopen(zsh_cmd, {
    on_exit = function()
      if _G._julia_read_handle then
        _G._julia_read_handle:read_stop()
        _G._julia_read_handle:close()
      end
      os.remove(pipe_path)
    end
  })
  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("JuliaWatchedZSH", M.launch_watched_zsh, {})

return M
