coords = ARGF.readlines.map { |line| line.strip.split(",").map(&:to_i) }

if ENV["PIC"]
  picture = []
  last_p = coords.last
  coords.each do |p|
    picture[p[1]] ||= []
    picture[p[1]][p[0]] = "#"
    case
    when last_p[0] == p[0]
      Range.new(*([p[1],last_p[1]].sort)).each do |y|
        picture[y] ||= []
        picture[y][p[0]] = "X" if picture[y][p[0]].nil?
      end
    when last_p[1] == p[1]
      Range.new(*([p[0],last_p[0]].sort)).each do |x|
        picture[p[1]][x] = "X" if picture[p[1]][x].nil?
      end
    else
      raise "#{p} #{last_p} womp womp"
    end
    last_p = p
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
  l = (p1[0] - p2[0]).abs + 1
  w = (p1[1] - p2[1]).abs + 1
  l * w
end

def midpoint(p1, p2)
  [
    (p1[0] + p2[0]) / 2,
    (p1[1] + p2[1]) / 2,
  ]
end

class Bounds
  def initialize
    #@edges_by_x = Hash.new { |h, k| h[k] = [] }
    @edges_by_y = Hash.new { |h, k| h[k] = [] }
    @cache = {}
  end
  def add_edge(p1, p2)
    case
    when p1[1] == p2[1]
      p add_edge: [p1, p2]
      @edges_by_y[p1[1]] << [p1[0], p2[0]].sort
    when p1[0] == p2[0]
      # not needed
    else
      raise "huh #{p1} #{p2}"
    end
    nil
  end
  def contains?(p)
    n = count_edges(p)
    puts({p: p, n: n}.inspect)
    n % 2 == 1
  end
  private
  def count_edges(p)
    px, py = p
    n = 0
    py.downto(0) do |y|
      if cn = @cache[[px,y]]
        n += cn
        break
      end
      if @edges_by_y.key?(y) && @edges_by_y[y].any? { |x1, x2| x1 < px && px < x2 }
        n += 1
      end
      puts({
        test_point: [px, y],
        edges_found: n,
        found_edges: @edges_by_y[y],
      }.inspect)
      @cache[[px,y]] = n
    end
    puts({summary_for: p, edges_found: n})
    n
  end
end

bounds = Bounds.new
coords.each_with_index do |p, i|
  bounds.add_edge(p, i == 0 ? coords.last : coords[i-1])
end

max_area1 = 0
max_area2 = 0
coords.each_with_index do |p1, i|
  rest = coords[i+2..] or next
  rest.each do |p2|
    a = area(p1, p2)
    p check_rect: [p1, p2], a: a
    max_area1 = [max_area1, a].max
    if a > max_area2 && bounds.contains?(midpoint(p1, p2))
      puts "========> update part 2"
      max_area2 = a
    end
  end
end
puts max_area1, max_area2
