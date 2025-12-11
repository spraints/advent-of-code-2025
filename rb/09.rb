coords = ARGF.readlines.map { |line| line.strip.split(",").map(&:to_i) }

def area(p1, p2)
  l = (p1[0] - p2[0]).abs + 1
  w = (p1[1] - p2[1]).abs + 1
  l * w
end

max_area = 0
coords.each_with_index do |p1, i|
  coords[i+1..].each do |p2|
    max_area = [max_area, area(p1, p2)].max
  end
end
puts max_area
