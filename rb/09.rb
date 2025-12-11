class Coord
  def initialize(pt)
    @x = pt[0]
    @y = pt[1]
  end
  attr_reader :x, :y
  def <=>(other)
    [self.x, self.y] <=> [other.x, other.y]
  end
  def inspect
    [self.x, self.y].inspect
  end
end

coords = ARGF.readlines.map { |line| Coord.new(line.strip.split(",").map(&:to_i)) }

if ENV["PIC"]
  picture = []
  last_pt = coords.last
  coords.each do |pt|
    line = (picture[pt.y] ||= [])
    line[pt.x] = "#"
    case
    when last_pt.x == pt.x
      Range.new(*([pt.y,last_pt.y].sort)).each do |y|
        picture[y] ||= []
        picture[y][pt.x] = "X" if picture[y][pt.x].nil?
      end
    when last_pt.y == pt.y
      Range.new(*([pt.x,last_pt.x].sort)).each do |x|
        line[x] = "X" if line[x].nil?
      end
    else
      raise "#{pt} #{last_pt} womp womp"
    end
    last_pt = pt
  end
  max_line = picture.map { |l| l.nil? ? 0 : l.size }.max
  printf "       %s\n", (0..max_line).map { |i| i % 10 }.join
  picture.each_with_index do |line, i|
    if line.nil?
      printf "%6d|\n", i
    else
      printf "%6d|%s\n",
        i, line.map { |c| c || " " }.join
    end
  end
end

def area(p1, p2)
  l = (p1.x - p2.x).abs + 1
  w = (p1.y - p2.y).abs + 1
  l * w
end

class Bounds
  def initialize
    @vertical_edges = []
    @horizontal_edges = []
  end
  def add_edge(p1, p2)
    edge = [p1, p2].sort
    case
    when p1.x == p2.x
      @vertical_edges << edge
    when p1.y == p2.y
      @horizontal_edges << edge
    else
      raise "huh #{p1} #{p2}"
    end
    nil
  end
  def contains?(pt)
    n = count_edges(pt)
    n % 2 == 1
  end
  private
  def count_edges(pt)
    vert_matches = @vertical_edges.select { |e|
      e1, e2 = e
      #p check: e, px: pt.x, py: pt.y,
      #  xok: e1.x == pt.x && e1.x == pt.x,
      #  yok: e1.y <= pt.y && pt.y <= e2.y
      e1.x == pt.x && e1.x == pt.x && e1.y <= pt.y && pt.y <= e2.y
    }

    n = vert_matches.size
    pp summary_for: pt, n: n, vert: vert_matches
    n
  end
  require "pp"
end

bounds = Bounds.new
coords.each_with_index do |pt, i|
  bounds.add_edge(pt, i == 0 ? coords.last : coords[i-1])
end

max_area1 = 0
max_area2 = 0
coords.each_with_index do |p1, i|
  rest = coords[i+2..] or next
  rest.each do |p2|
    a = area(p1, p2)
    p check_rect: [p1, p2], a: a
    max_area1 = [max_area1, a].max
    if a > max_area2
      # Check if all 4 corners are inside the shape.
      contained = [p1.x, p2.x].all? do |x|
        [p1.y, p2.y].all? do |y|
          bounds.contains?(Coord.new([x, y]))
        end
      end
      if contained
        puts "========> update part 2"
        max_area2 = a
      end
    end
  end
end
puts max_area1, max_area2
