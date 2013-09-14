a = [{ b: 6, c: 2, d: %w(hello how are you) }, { b: 12, c: 7, d: %w(fine thank you) }, { b: 10, c: 1, d: %w(jolly good then)}]

# # index_of_max = maximum = 0
# # a.count.times do |i|
# # puts a[index_of_max]
# chordness = []

# a.each do |hash|
#   chordness << hash[:d].sort if hash[:d].include?("you")
# end
# print chordness.sort

# b = [[1, 2, 3], [5, 4, 6], [3, 4, 1]]

# print "#{b.sort_by!{ |i| i[2] }}.\n"

# print "#{b}.\n"

c = [[[:hello], [:hello], [:help]], [[:hello], [:hello], [:hello]], [[:hello], [:hello], [:hello]], [[:hello], [:hello], [:hello]]]

puts (c[0] - [[:hello]])
puts (c[0] - [[:hello]]).empty?
