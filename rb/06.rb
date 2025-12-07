homework = ARGF.readlines
ops = homework.pop

def calc(op, ns)
  if op == "+"
    ns.inject(&:+)
  else
    ns.inject(&:*)
  end
end

part1 = 0
part2 = 0
cur_op = p1 = p2 = nil
ops.chars.each_with_index do |op, i|
  if op != " "
    if cur_op
      # p op: cur_op, p1: p1, p2: p2
      part1 += calc(cur_op, p1)
      part2 += calc(cur_op, p2)
    end
    cur_op = op
    p1 = [0] * homework.size
    p2 = []
  end

  n = 0
  homework.each_with_index do |line, j|
    c = line[i]
    next if c == " "
    d = c.to_i
    p1[j] = p1[j] * 10 + d
    n = n * 10 + d
  end
  p2 << n if n > 0
end
# p op: cur_op, p1: p1, p2: p2
part1 += calc(cur_op, p1)
part2 += calc(cur_op, p2)

puts part1, part2
