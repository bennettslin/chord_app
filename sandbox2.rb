a = [{ b: 6, c: 2, d: %w(hello how are you) }, { b: 12, c: 7, d: %w(fine thank you) }, { b: 10, c: 1, d: %w(jolly good then)}]

# index_of_max = maximum = 0
# a.count.times do |i|
# puts a[index_of_max]
chordness = []

a.each do |hash|
  chordness << hash[:d].sort if hash[:d].include?("you")
end
print chordness.sort


