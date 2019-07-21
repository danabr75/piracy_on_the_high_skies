# Not quite working, and also way too slow
# Credit; https://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=816
require_relative 'point_3_d.rb'

class Object3D

  def self.read_file(filePath)
    obj = Object3D.new("obj")
    contents = []
    File.open(filePath, "rb") do |file|
      contents = file.read.split("\n")
    end
    for line in contents do
      line = line.split(" ")
      case line.delete_at(0)
      when "v"
        obj << Point3D.new(line[0].to_f, line[1].to_f, line[2].to_f)
      when "f"
        points = line.map{|point| point.split("/")[0].to_i - 1}
        obj << points
      end
    end
    obj.rotX(Math::PI)
    return obj
  end

  attr_reader :name, :points, :lines, :faces, :triangles
  def initialize(name)
    @x = @y = @z = 0
    @name = name
    @points = []
    @lines = []
    @faces = []
    @triangles = []
  end

  def update
  end

  def draw
    for face in @faces do
            p1 = @points[face[0]]
            p2 = @points[face[1]]
            p3 = @points[face[2]]
            p4 = @points[face[3]]
            x1, y1 = p1.toScreen
            x2, y2 = p2.toScreen
            x3, y3 = p3.toScreen
            x4, y4 = p4.toScreen
            Gosu::draw_quad(x1, y1, p1.col, x2, y2, p2.col, x3, y3, p3.col, x4, y4, p4.col, 0 - (p1.dtc + p2.dtc + p3.dtc + p4.dtc) / 4)
        end
    for triangle in @triangles do
      p1 = @points[triangle[0]]
      p2 = @points[triangle[1]]
      p3 = @points[triangle[2]]
      x1, y1 = p1.toScreen
      x2, y2 = p2.toScreen
      x3, y3 = p3.toScreen
      Gosu::draw_triangle(x1, y1, p1.col, x2, y2, p2.col, x3, y3, p3.col, 0 - (p1.dtc + p2.dtc + p3.dtc) / 3)
    end
        for line in @lines do
            p1 = @points[line[0]]
            p2 = @points[line[1]]
            x1, y1 = p1.toScreen
            x2, y2 = p2.toScreen
            Gosu::draw_line(x1, y1, 0xff_000000, x2, y2, 0xff_000000, 1 - (p1.dtc + p2.dtc) / 2)
        end
  end

  def rotY(angle)
    @points.each{|p| p.rotY(angle)}
  end

  def rotX(angle)
    @points.each{|p| p.rotX(angle)}
  end

  def rotZ(angle)
    @points.each{|p| p.rotZ(angle)}
  end

  def rotCenter(x, y, z)
    posx = @x
    posy = @y
    posz = @z
    move(-posx, -posy, -posz)
    rotX(x)
    rotY(y)
    rotZ(z)
    move(posx, posy, posz)
  end

  def move(x, y, z)
    @x += x
    @y += y
    @z += z
    @points.each do |p|
      p.x += x
      p.y += y
      p.z += z
    end
  end

  def <<(other)
    if other.is_a? Point3D
      @points << other
    else
      case other.size
      when 2
        @lines << other
      when 3
        @triangles << other
      when 4
        @faces << other
      end
    end
  end
end