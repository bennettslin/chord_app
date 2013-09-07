a = [[4, 5, 6], [5, 6, 7], [1, 2, 3], [4, 2, 1]]
b = Array.new
# a.each { |i| b << i[1] }

a.count.times { |i| b << a[i][1] }

print b

