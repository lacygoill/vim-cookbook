local function compute(msg, lines)
  new_lines = {}
  for _, line in ipairs(lines) do
    table.insert(new_lines, string.format(msg, string.len(line)))
  end
  return new_lines
end

return {
  new_lines = compute,
}

