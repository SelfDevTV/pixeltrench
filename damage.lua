damage_nums = {}

function create_damage_num(x, y, amount)
  local dam = {
    x = x,
    y = y,
    amount = amount,
    ttl = 0.4
  }
  add(damage_nums, dam)
end

function update_damage_nums()
  for i = #damage_nums, 1, -1 do
    local dam = damage_nums[i]
    dam.y -= 0.3
    dam.ttl -= 1 / 60
    if dam.ttl <= 0 then
      deli(damage_nums, i)
    end
  end
end

function draw_damage_nums()
  for dam in all(damage_nums) do
    print("- " .. dam.amount, dam.x, dam.y, 14)
  end
end
