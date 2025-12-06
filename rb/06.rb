homework = ARGF.readlines.map { |line| line.strip.split }
part1 = 0
part2 = 0
ops = homework.pop
ops.each_with_index do |op, i|
  ns = homework.map { |l| l[i] }
  p1 = ns.map(&:to_i)
  p2 = ns.map(&:reverse).map(&:to_i)
  case op
  when "+"
    part1 += p1.inject(&:+)
    part2 += p2.inject(&:+)
  when "*"
    part1 += p1.inject(&:*)
    part2 += p2.inject(&:*)
  else
    raise "invalid op[#{i}] #{op.inspect}"
  end
end
puts part1, part2
