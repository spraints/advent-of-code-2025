points = ARGF.readlines.map { |line| line.strip.split(",").map(&:to_i) }
goal =
  case points.size
  when 20
    # sample
    10
  when 1000
    # real
    1000
  else
    abort "unknown goal"
  end

def dist(a, b)
  # d1 = sqrt( (bx - ax)^2 + (by - ay)^2 )
  # d2 = sqrt( d1^2 + (bz - az)^2 )
  # d2 = sqrt( (bx - ax)^2 + (by - ay)^2 + (bz - az)^2 )
  raise "invalid #{a.size} vs #{b.size}" if a.size != b.size
  squares = a.zip(b).map { |aa, bb| (aa.to_f - bb.to_f)**2 }
  Math.sqrt(squares.sum)
end

dists = []
circuits = {}
loners = Set.new
larger_than_1 = []
points.each_with_index do |p1, i|
  circuits[p1] = [p1]
  loners << p1
  points[i+1..].each_with_index do |p2, j|
    dists << [dist(p1, p2), p1, p2]
  end
end
dists.sort!
(0..goal-1).each do |i|
  dist, p1, p2 = dists[i]
  c1 = circuits.fetch(p1)
  loners.delete(p1)
  c2 = circuits.fetch(p2)
  loners.delete(p2)
  if c1 == c2
    #puts "redundant"
    next
  end
  #p p1: p1, p2: p2, dist: dist
  #p c1: c1, c2: c2
  #p loners: loners.to_a.sort
  #require "pp"; pp merge: [c1, c2]
  combined = c1 + c2
  combined.each do |p|
    circuits[p] = combined
  end
  larger_than_1.delete(c1)
  larger_than_1.delete(c2)
  larger_than_1 << combined
end

#require "pp"; pp larger_than_1

puts larger_than_1.map(&:size).sort_by { |x| -x }.take(3).inject(&:*)

(goal..).each do |i|
  dist, p1, p2 = dists[i]

  c1 = circuits.fetch(p1)
  loners.delete(p1)

  c2 = circuits.fetch(p2)
  loners.delete(p2)

  if c1 == c2
    #puts "redundant"
    next
  end

  #p p1: p1, p2: p2, dist: dist
  #p c1: c1, c2: c2
  #p loners: loners.to_a.sort, globs: larger_than_1.map(&:size)

  larger_than_1.delete(c1)
  larger_than_1.delete(c2)
  if loners.empty? && larger_than_1.empty?
    puts p1[0] * p2[0]
    break
  end

  #require "pp"; pp merge: [c1, c2]
  combined = c1 + c2
  combined.each do |p|
    circuits[p] = combined
  end
  larger_than_1 << combined
end
