function clamp(v, lo, hi)
  return mid(lo, v, hi)
end

function lerp(a, b, t)
  return (1 - t) * a + b * t
end
