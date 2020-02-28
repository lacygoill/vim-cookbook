local function main()
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, false,
    {relative='win', width=12, height=3, bufpos={12,34}, row=0, col=0, style='minimal'})
    --                                   ^^^^^^^^^^^^^^
    -- The float does not start on the 34th cell!  Why?{{{
    --
    -- First, the  indexes in `bufpos` do  not describe any type  of cells; only
    -- cells containing a character in a buffer.
    -- So, don't start  counting from the very first cell;  count from the first
    -- cell where a character in the buffer is drawn.
    --
    -- Second, if  the line you specified  is too short (i.e.  it contains fewer
    -- than 34 characters), Nvim clamps up `34` to the nearest valid value (i.e.
    -- the last column on the line).
    --}}}
end

return {
  main = main,
}
