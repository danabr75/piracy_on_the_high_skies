# Not quite working, and also way too slow
# Credit; https://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=816

class Point3D
    attr_accessor :x, :y, :z
    def initialize(x, y, z)
        @x = x
        @y = y
        @z = z
    @hue = rand(360)
    end

    def + (other)
        return Point3D.new(@x + other.x, @y + other.y, @z + other.z)
    end

    def - (other)
        return Point3D.new(@x - other.x, @y - other.y, @z - other.z)
    end

  def rotX(angle)
        y = @y * Math.cos(angle) - @z * Math.sin(angle)
        z = @y * Math.sin(angle) + @z * Math.cos(angle)
        @y = y
        @z = z
    end

    def rotY(angle)
        z = @z * Math.cos(angle) - @x * Math.sin(angle)
        x = @z * Math.sin(angle) + @x * Math.cos(angle)
        @z = z
        @x = x
    end

  def rotZ(angle)
    x = @x * Math.cos(angle) - @y * Math.sin(angle)
    y = @x * Math.sin(angle) + @y * Math.cos(angle)
    @x = x
    @y = y
  end

  #distance to center
  def dtc
    x2 = @x.abs ** 2
    y2 = @y.abs ** 2
    z2 = @z.abs ** 2
    return Math::sqrt(x2 + y2 + z2)
  end

  def toScreen
      middlex = 500#$screenWidth / 2
      middley = 500#$screenHeight / 2
  z = @z
  z = 1 if z < 0
      x = (@x / (z * 0.01)) * 10
      y = (@y / (z * 0.01)) * 10
      x += middlex
      y += middley
      return x, y
  end

  def col
      return Gosu::Color.from_hsv(@hue, 1, 1)
  end

  def to_s
    return "Point X:#{@x} Y:#{@y} Z:#{@z}"
  end
end