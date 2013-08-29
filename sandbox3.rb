def methodAgain(x, y, z)
  x += 1
  y -= 2
  z *= 3
  return x, y, z
end

a, b, c, = methodAgain(5, 6, 7)

puts a, b, c
