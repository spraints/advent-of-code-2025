ranges, ingredients = ARGF.read.split("\n\n", 2)
ranges = ranges.strip.lines.map { |l| l.strip.split("-",2).map(&:to_i) }

iters = 0
fresh = 0
ingredients.strip.lines.each do |ing|
  ing = ing.strip.to_i
  fresh += 1 if ranges.any? { |a,b| iters += 1; a <= ing && ing <= b }
end
puts "(iterations: #{iters})", fresh

iters = 0
max = 0
spoiled = 0
ranges.sort.each do |a, b|
  if a > max
    spoiled += (a - max - 1)
  end
  max = [b, max].max
end
puts max - spoiled
