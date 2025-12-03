require "set"

ranges = ARGF.read.split(",").map(&:strip).map { |r| r.split("-", 2).map(&:to_i) }

invalid1 = 0
invalid2 = 0

seen = Set.new

max = ranges.flatten.max
l = 1
r = 10
iters = 0
loop do
  l2 = l * r + l
  break if l2 > max
  #p [l, r, l2]
  if !seen.include?(l2) && ranges.any? { |a,b| a <= l2 && l2 <= b }
    invalid1 += l2
    invalid2 += l2
    #p [:both, l2]
  end
  seen << l2
  loop do
    iters += 1
    l2 = l2 * r + l
    break if l2 > max
    #p [:more, l2]
    if !seen.include?(l2) && ranges.any? { |a,b| a <= l2 && l2 <= b }
      invalid2 += l2
      #p [:part2, l2]
    end
    seen << l2
  end

  l += 1
  r *= 10 if l == r
end

puts "(#{iters} iterations)"
puts invalid1, invalid2
