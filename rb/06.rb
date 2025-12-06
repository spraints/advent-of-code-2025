homework = ARGF.readlines.map { |line| line.strip.split }
total = 0
ops = homework.pop
homework = homework.map { |l| l.map(&:to_i) }
ops.each_with_index do |op, i|
  case op
  when "+"
    total += homework.map { |l| l[i] }.sum
  when "*"
    total += homework.map { |l| l[i] }.inject(&:*)
  else
    raise "invalid op[#{i}] #{op.inspect}"
  end
end
puts total
