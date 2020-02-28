local function main()
  --                            ┌ don't list the buffer
  --                            │      ┌ scratch buffer
  --                            │      │
  buf = vim.api.nvim_create_buf(false, true)
  --                         ┌ don't focus the float
  --                         │
  vim.api.nvim_open_win(buf, false, {
      relative='win',
      width=12,
      height=3,
      row=3,
      col=3,
      style='minimal',
      focusable=false,
    })
    -- The float starts on the column 2!  Why does it not respect the value 3?{{{
    --
    -- First, the value given to `col` is interpreted as the index of a *screen*
    -- cell, not as the index of a *text* column.
    --
    -- Second, this value is 0-indexed.
    -- So, `col=3` means that the float should start on the 4th screen cell.
    --
    -- Third, you probably  have set `'signcolumn'` which adds  a 2-cells column
    -- on the left.   So, the 2nd *text* column corresponds  to the 4th *screen*
    -- cell, which matches exactly the value you've set `col` to.
    --}}}
    -- Why `style='minimal'`?{{{
    --
    -- To hide/disable various visual features in the float.
    -- Among other things, the characters  highlighted by `EndOfBuffer`, and the
    -- signcolumn which would  take 2 valuable spaces at the  start of each line
    -- (not to mention that  they are not highlighted as the  rest of the window
    -- which is distracting).
    --}}}
end

return {
  -- ┌ name of the field in `luaeval('require(...).main()')`
  -- │                                            ^^^^
  -- │   ┌ name of the function in the current file
  -- │   │
  main = main,
  -- Yes, it seems you can use the same name in the two sides of the assignment.{{{
  --
  -- For a real example, see the very bottom of this article:
  -- https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua
  --
  -- But, you don't have to.
  --}}}
}

