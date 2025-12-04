banks = ARGF.readlines.map(&:strip).map { |l| l.chars.map(&:to_i) }
total_joltage = 0
banks.each do |batteries|
  #puts batteries.join("")
  9.downto(1).each do |x|
    i = batteries.index(x)
    next if i.nil?
    rest = batteries[(i+1)..]
    next if rest.size < 1
    y = rest.max
    n = x * 10 + y
    #puts "==> #{n}"
    total_joltage += n
    break
  end
end
puts total_joltage
