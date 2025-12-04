def max_j(ary, n, left = 0)
  if n == 0
    dbg "=a=> #{n}: #{left}"
    return left
  end
  if ary.size == n
    tot = ary.inject(left) { |accum, x| accum * 10 + x }
    dbg "=b=> #{n}: #{tot}"
  end
  9.downto(1).each do |x|
    i = ary.index(x)
    next if i.nil?
    dbg "#{x}@#{i}, need #{n-1} more"
    if tot = max_j(ary[(i+1)..], n - 1, left * 10 + x)
      dbg "=c=> #{n}(#{x}): #{tot}"
      return tot
    end
  end
  nil
end

def dbg(*x)
  # puts(*x)
end

banks = ARGF.readlines.map(&:strip).map { |l| l.chars.map(&:to_i) }
total_joltage = 0
total_joltage2 = 0
banks.each do |batteries|
  dbg batteries.join("")
  js = max_j(batteries, 2)
  total_joltage += js
  js = max_j(batteries, 12)
  total_joltage2 += js
end
puts total_joltage, total_joltage2
