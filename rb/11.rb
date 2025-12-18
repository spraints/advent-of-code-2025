require "set"

paths = {}
ARGF.each_line do |line|
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

puts count_paths(paths, "you")
