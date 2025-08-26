function drawdebug()
  local x, y, c, sc = 1, 1, 7, 2
  -- deterministische reihenfolge
  for i, k in ipairs(dbg_keys) do
    local v = dbg_fns[k]
    local line = k .. ": " .. v()
    -- shadow fれもr bessere lesbarkeit
    print(line, x + 1, y + 1, sc)
    print(line, x, y, c)
    y += 6
  end
end
