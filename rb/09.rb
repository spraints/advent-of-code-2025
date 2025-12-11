coords = ARGF.readlines.map { |line| line.strip.split(",").map(&:to_i) }

def area(p1, p2)
  l = (p1[0] - p2[0]).abs + 1
  w = (p1[1] - p2[1]).abs + 1
  l * w
end

max_x, max_y = 0, 0
max_area = 0
coords.each_with_index do |p1, i|
  max_x = [p1[0],max_x].max
  max_y = [p1[1],max_y].max
  coords[i+1..].each do |p2|
    max_area = [max_area, area(p1, p2)].max
  end
end
puts max_area

picture = (0..max_y+1).map { |_| "." * (max_x+2) }
last_p = coords.last
coords.each do |p|
  picture[p[1]][p[0]] = "#"
  case
  when last_p[0] == p[0]
    Range.new(*([p[1],last_p[1]].sort)).each do |y|
      picture[y][p[0]] = "X" if picture[y][p[0]] == "."
    end
  when last_p[1] == p[1]
    Range.new(*([p[0],last_p[0]].sort)).each do |x|
      picture[p[1]][x] = "X" if picture[p[1]][x] == "."
    end
  else
    raise "#{p} #{last_p} womp womp"
  end
  last_p = p
end
puts picture
