local M = {}

function M.setup_julia_walkback()
  local bufnr = vim.api.nvim_get_current_buf()
  local last_julia_output = {}

  vim.api.nvim_create_autocmd("TextChangedT", {
    buffer = bufnr,
    callback = function()
      local total_lines = vim.api.nvim_buf_line_count(bufnr)
      local lookback = 1000
      local start_idx = math.max(0, total_lines - lookback)
      local history = vim.api.nvim_buf_get_lines(bufnr, start_idx, -1, false)

      local bottom_prompt_idx = nil
      local top_prompt_idx = nil
      local is_different = false
      local current_section = {}

      -- 1. Walk backwards to find the bottom prompt (end of output)
      for i = #history, 1, -1 do
        if history[i]:match("julia>") then
          bottom_prompt_idx = i
          break
        end
      end

      -- 2. If we found the bottom prompt, walk back further to find the top prompt
      if bottom_prompt_idx then
        for i = bottom_prompt_idx - 1, 1, -1 do
          if history[i]:match("julia>") then
            top_prompt_idx = i
            break
          end

          -- While walking between prompts, build the section and check for differences
          local line_content = history[i]
          table.insert(current_section, 1, line_content) -- Build top-down

          -- Compare with history using the flag
          -- Indexing offset: last_julia_output is compared against current collection
          local history_line = last_julia_output[#current_section]
          if line_content ~= history_line then
            is_different = true
          end
        end
      end


      -- 3. Final check: if we found both bounds and the content changed
      if top_prompt_idx and bottom_prompt_idx then
        -- Also check if the number of lines changed
        if #current_section ~= #last_julia_output then
          is_different = true
        end

        if is_different then
          vim.cmd('Errorformat julia')
          vim.fn.setqflist({}, 'r', {
            title = "Julia Output",
            lines = current_section
          })
          last_julia_output = current_section
        end
      end
    end
  })
end

vim.api.nvim_create_user_command("JuliaToQF", M.setup_julia_walkback, {})

return M
