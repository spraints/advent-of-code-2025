DEBUG = !ENV["DEBUG"].nil?
SHOW_PIC = !ENV["SHOW_PIC"].nil?

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
  def ==(other)
    self.x == other.x && self.y == other.y
  end
  def eql?(other)
    self.x == other.x && self.y == other.y
  end
  def hash
    [self.x, self.y].hash
  end
end

coords = ARGF.readlines.map { |line| Coord.new(line.strip.split(",").map(&:to_i)) }

if SHOW_PIC
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

def vert_edge_dir(edge, pt, verbose)
  ep1, ep2 = edge
  case
  when ep1.y < pt.y && pt.y < ep2.y
    puts "from #{pt} to #{edge}: cross" if verbose
    :cross
  when ep1.y == pt.y && ep2.y < pt.y
    puts "from #{pt} to #{edge}: up1" if verbose
    :up
  when ep2.y == pt.y && ep1.y < pt.y
    puts "from #{pt} to #{edge}: up2" if verbose
    :up
  when ep1.y == pt.y && ep2.y > pt.y
    puts "from #{pt} to #{edge}: down1" if verbose
    :down
  when ep2.y == pt.y && ep1.y > pt.y
    puts "from #{pt} to #{edge}: down2" if verbose
    :down
  else
    puts "from #{pt} to #{edge}: ???" if verbose
    :unknown
  end
end

class Bounds
  def initialize
    @vertical_edges = {} # x => [y1, y2]
    @horizontal_edges = {} # y => [x1, x2]
    @max_x = 0
    @max_y = 0
    @cache = {}
  end
  attr_reader :max_x, :max_y
  def add_edge(p1, p2)
    @max_x = [@max_x, p1.x, p2.x].max
    @max_y = [@max_y, p1.y, p2.y].max
    case
    when p1.x == p2.x
      (@vertical_edges[p1.x] ||= []) << [p1.y, p2.y].sort
    when p1.y == p2.y
      (@horizontal_edges[p1.y] ||= []) << [p1.x, p2.x].sort
    else
      raise "huh #{p1} #{p2}"
    end
    nil
  end
  # Example:
  # pt = [100,100]
  # dir = [-1, -1]
  # contains?(pt, dir)
  def contains?(pt, dir, verbose:)
    p start: "contains", pt: pt, dir: dir if verbose

    k = [pt, dir]
    return @cache[k] if @cache.key?(k) && !verbose

    count = 0
    x, y = pt
    dx, dy = dir
    while 0 < x && x <= @max_x && 0 < y && y <= @max_y
      if on_edge?(x, y)
        count += 1
        p point_crosses_edge: [x, y] if verbose
      end
      x += dx
      y += dy
    end
    p fn: :contains?, pt => count if verbose
    res = count % 2 == 1
    @cache[k] = res
    res
  end
  private
  def on_edge?(x, y)
    if ve = @vertical_edges[x]
      return true if ve.any? { |y1, y2| y1 <= y && y <= y2 }
    end
    if he = @horizontal_edges[y]
      return true if he.any? { |x1, x2| x1 <= x && x <= x2 }
    end
    false
  end
end

bounds = Bounds.new
coords.each_with_index do |pt, i|
  bounds.add_edge(pt, i == 0 ? coords.last : coords[i-1])
end

def in_bounds?(bounds, p1, p2, verbose:)
  # Check if all 4 corners are inside the shape.
  xmin, xmax = [p1.x, p2.x].sort
  ymin, ymax = [p1.y, p2.y].sort
  ok = bounds.contains?([xmin+1, ymin+1], [ 1,  1], verbose: verbose) &&
    bounds.contains?([xmax-1, ymin+1], [-1,  1], verbose: verbose) &&
    bounds.contains?([xmax-1, ymax-1], [-1, -1], verbose: verbose) &&
    bounds.contains?([xmin+1, ymax-1], [ 1, -1], verbose: verbose)
  p in_bounds: [p1, p2], res: ok if verbose
  ok
end

max_area1 = 0
max_area2 = 0
coords.each_with_index do |p1, i|
  rest = coords[i+2..] or next
  rest.each_with_index do |p2, j|
    printf "\r%4d x %4d", i, j
    a = area(p1, p2)
    next if a < 1
    verbose = DEBUG && a == 1704850740
    p check_rect: [p1, p2], a: a if verbose
    max_area1 = [max_area1, a].max
    if a > max_area2
      if in_bounds?(bounds, p1, p2, verbose: verbose)
        puts "========> update part 2 = #{a}" if verbose
        max_area2 = a
      end
    end
  end
end
puts "", max_area1, max_area2
