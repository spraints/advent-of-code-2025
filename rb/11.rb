require "set"

paths = {}
want = %w[you svr dac fft]
has = {}
ARGF.each_line do |line|
  want.each do |w|
    if line =~ /#{w}/
      has[w] = true
    end
  end
  src, dsts = line.split(":", 2)
  paths[src] = dsts.strip.split
end

def count_paths(paths, src, memo = {})
  return memo[src] if memo[src]
  res = 0
  paths[src].each do |n|
    case n
    when "out"
      res += 1
    else
      res += count_paths(paths, n, memo)
    end
  end
  memo[src] = res
end

puts "part 1: #{count_paths(paths, "you")}" if has["you"]

def count_paths2(paths, src, memo: {}, fft: false, dac: false, trace: [])
  # p cur: src, fft: false, dac: false, trace: trace
  k = [src, fft, dac]
  return memo[k] if memo[k]
  res = 0
  paths[src].each do |n|
    t2 = trace + [n]
    case n
    when "out"
      # p t2
      res += 1 if fft && dac
    when "fft"
      res += count_paths2(paths, n, memo: memo, fft: true, dac: dac, trace: t2)
    when "dac"
      res += count_paths2(paths, n, memo: memo, fft: fft, dac: true, trace: t2)
    else
      res += count_paths2(paths, n, memo: memo, fft: fft, dac: dac, trace: t2)
    end
  end
  memo[k] = res
end

puts "part 2: #{count_paths2(paths, "svr")}" if has["svr"] && has["fft"] && has["dac"]
