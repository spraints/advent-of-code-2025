invalid = 0
ARGF.read.split(",").map(&:strip).each do |range|
  from, to = range.split("-", 2)
  exp = from.size
  from, to = from.to_i, to.to_i
  #p [from, to, exp]
  exp = (exp + 1) / 2
  r = 10**exp
  l = from / r
  while l * r < to
    lmin = 10**(exp - 1)
    l = [l, lmin].max
    l.upto(r-1) do |i|
      #p i: i, xy: i*r+i
      xy = i * r + i
      next if xy < from
      break if xy > to
      #puts xy
      invalid += xy
    end
    l = r
    r *= 10
  end
end
puts invalid
