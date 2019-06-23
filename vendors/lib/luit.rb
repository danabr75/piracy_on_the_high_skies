# # Leddys UI Toolkit, LUIT
# # Copyrigth 2017 Martin Larsson
# # martin.99.larsson@telia.com
# #
# # a holder is the object wich will recieve a callback when something happens to an element
# # this could be button presse, or other similar events
# # the id is assigned by the holder to know wich element called the callback method
# raise "STOP HERE"

require 'gosu'

module LUIT
  class << self
    attr_accessor :uiColor, :uiColorLight, :touchDown
    attr_reader :window, :z
  end

  def self.config(window:, uiColor: 0xff_555555, uiColorLight: 0xff_888888, z: 100)
    @window = window
    @uiColor = uiColor
    @uiColorLight = uiColorLight
    # @z = z
    @touchDown = false
  end

  def self.mX
    @window.mouse_x
  end

  def self.mY
    @window.mouse_y
  end

  #Raspberry pi touchscreen hack
  def self.updateTouch()
    if @touchDown
      @window.mouse_x = 0
      @window.mouse_y = 0
      @touchDown = false
    else
      if @window.mouse_x != 0 or @window.mouse_y != 0
        @touchDown = true
      end
    end
  end

  class LUITElement
    attr_reader :id, :x, :y, :w, :h, :hover
    def initialize(holder, id, x, y, z, w, h, color = nil, hover_color = nil)
      @holder = holder
      @id = id
      @x = x
      @y = y
      @w = w
      @h = h
      @z = z
      @msDown = false
      @hover = true
      @hover_color = color || LUIT.uiColorLight
      @color       = hover_color || LUIT.uiColor

    end

    def draw(x = 0, y = 0)
    end

    def draw_rel(x = 0, y = 0)
      draw(x - (@w/2), y - (@h/2))
    end

    def updateHover(x, y)
      @hover = LUIT.mX.between?(x, x + @w) && LUIT.mY.between?(y, y + @h)
    end

    def update(x = 0, y = 0)
      if Gosu::button_down?(Gosu::MsLeft) or LUIT.touchDown
        if !@msDown
          button_down(Gosu::MsLeft)
        end
        @msDown = true
      else
        @msDown = false
      end
    end

    def update_rel(x = 0, y = 0)
      update(x - (@w/2), y - (@h/2))
    end

    def button_down(id)
      if id == Gosu::MsLeft && @hover
        @holder.onClick(@id)
      end
    end
  end

  class ClickArea < LUITElement
    def initialize(holder, id, x, y, z, w = 0, h = 0, color = nil, hover_color = nil, options = {})
      puts "INITING H HERE: #{h}"
      h = [1, h].max
      puts "NEW H IS : #{h}"
      w = [1, w].max
      puts "HOVLER COLOR: #{hover_color }"
      @hide_rect_draw = options[:hide_rect_draw]
      super(holder, id, x, y, z, w, h, color, hover_color)
    end

    def draw(x = 0, y = 0)
      # puts "DRAWING HOVER: #{@hover_color}" if @hover
      # puts "WHAT IS H?: #{@h}" if @hover
          # .draw_rect(x, y, z, width, height, c, z = 0, mode = :default) ⇒ void
      if !@hide_rect_draw 
        Gosu::draw_rect(@x + x, @y + y, @w, @h, @hover ? @hover_color : @color, @z)
      end
    end
    # def update(x = 0, y = 0)
    #   if Gosu::distance($mx, $my, x, y) <= @r
    #     @hover = true
    #   else
    #     @hover = false
    #   end
    # end
    def update(x = 0, y = 0)
      x += @x
      y += @y
      is_hover = updateHover(x, y)
      super(x, y)
      return is_hover
    end
  end

  class TextArea < LUITElement
    attr_reader :field
    def initialize(holder, id, x, y, z, maxChar, h)
      h = [10, h].max
      @font = Gosu::Font.new(h)
      w = @font.text_width("W" * maxChar) + 20
      @maxChar = maxChar
      super(holder, id, x, y, z, w, h + 20)
      @typing = false
      @field = Gosu::TextInput.new
      puts "WINDOW HERE: "
      @window = LUIT.window
      puts @window
    end

    def text
      return @field.text
    end

    def button_down(id)
      if @hover
        @typing = true
      else
        if @typing
          @typing = false
          @holder.onClick(@id)
        end
      end
    end

    def draw(x = 0, y = 0)
      x = x + @x
      y = y + @y
      Gosu::draw_rect(x, y, @w, @h, @typing ? 0xffffffff : LUIT.uiColor, @z)
      @font.draw(@field.text, x + 10, y + 10, @z + 1, 1, 1, 0xff000000)
    end

    def update(x = 0, y = 0)
      super
      x += @x
      y += @y
      updateHover(x, y)
      if @field.text.size > @maxChar
        @field.text = @field.text[0..@maxChar]
      end
      if @typing
        @window.text_input = @field
      elsif @window.text_input == @field
        @window.text_input = nil
      end
      if Gosu::button_down?(Gosu::KbReturn) && @typing
        @typing = false
        @window.text_input = nil
        @holder.onClick(@id)
      end
    end
  end

  class ScannerInput
    attr_reader :scanning, :field
    def initialize(holder, id)
      @field = Gosu::TextInput.new
      @window = LUIT.window
      @holder = holder
      @id = id
    end

    def stop
      @scaning = false
      @window.text_input = nil if @window.text_input == @field
    end

    def scan
      @scaning = true
      @window.text_input = @field
    end
  end

  class ClickPoint < LUITElement
    def initialize(holder, id, x, y, z, r)
      @r = [1, r].max
      super(holder, id, x - @r, y - @r, z, @r * 2, @r * 2)
    end

    def update(x = 0, y = 0)
      if Gosu::distance($mx, $my, x, y) <= @r
        @hover = true
      else
        @hover = false
      end
    end
  end

  class Button < LUITElement
    #w and h will auto adjust to the text size + 10px padding if its not set (or set lower than acceptable)
    def initialize(holder, id, x, y, z, text, w = 0, h = 0)
      h = [50, h].max
      @text = text
      @buttonColor = LUIT.uiColor
      @font = Gosu::Font.new(h - 20)
      @textW = @font.text_width(@text)
      w = @textW + 20 if w < @textW + 20
      super(holder, id, x, y, z, w, h)
    end

    def draw(x = 0, y = 0)
      Gosu::draw_rect(x + @x, y + @y, @w, @h, @hover ? LUIT.uiColorLight : LUIT.uiColor, @z)
      @font.draw_rel(@text, @x + x + @w / 2, @y + y + @h / 2, @z + 1, 0.5, 0.5)
    end

    def update(x = 0, y = 0)
      x += @x
      y += @y
      updateHover(x, y)
      super(x, y)
    end
  end

  class Slider < LUITElement
    attr_accessor :value
    def initialize(holder, id, x, y, z, range)
      super(holder, id, x, y, range + 10, 30)
      @range = range
      @value = 0
      @buttonColor = LUIT.uiColor
    end

    def draw(x = 0, y = 0)
      Gosu::draw_rect(@x + x, @y + y + 10, @w, 10, @buttonColor, @z)
      Gosu::draw_rect(@x + x + @value, @y + y, 10, @h, @buttonColor, @z + 1)
    end

    def updateHover(x, y)
      @hover = LUIT.mX.between?(x - 10, x + @w + 20) && LUIT.mY.between?(y - 10, y + @h + 20)
    end

    def update(x = 0, y = 0)
      x += @x
      y += @y
      updateHover(x, y)
      if @hover && (Gosu::button_down?(Gosu::MsLeft) or LUIT.touchDown)
        @value = LUIT.mX - (x + 5)
        @value = 0 if @value < 0
        @value = @range if @value > @range
      end
      @buttonColor = @hover ? LUIT.uiColorLight : LUIT.uiColor
    end

    def button_down(id)
    end
  end

  class VerticalSlider < LUITElement
    attr_accessor :value
    def initialize(holder, id, x, y, z, range)
      super(holder, id, x, y, 30, range + 10)
      @range = range
      @value = 0
      @buttonColor = LUIT.uiColor
    end

    def draw(x = 0, y = 0)
      Gosu::draw_rect(@x + x + 10, @y + y, 10, @h, @buttonColor, @z)
      Gosu::draw_rect(@x + x, @y + y  + @value, @w, 10, @buttonColor, @z + 1)
    end

    def updateHover(x, y)
      @hover = LUIT.mX.between?(x - 10, x + @w + 20) && LUIT.mY.between?(y - 10, y + @h + 20)
    end

    def update(x = 0, y = 0)
      x += @x
      y += @y
      updateHover(x, y)
      if @hover && (Gosu::button_down?(Gosu::MsLeft) or LUIT.touchDown)
        @value = LUIT.mY - (y + 5)
        @value = 0 if @value < 0
        @value = @range if @value > @range
      end
      @buttonColor = @hover ? LUIT.uiColorLight : LUIT.uiColor
    end

    def button_down(id)
    end
  end

  class Toggle < LUITElement
    attr_accessor :value
    def initialize(holder, id, x, y, z, size = 30)
      h = [30, size].max
      w = h * 2
      super(holder, id, x, y, z, w, h)
      @buttonColor = LUIT.uiColor
      @value = false
    end

    def draw(x = 0, y = 0)
      x += @x
      y += @y
      Gosu::draw_rect(x, y, @w, @h, @buttonColor, @z)
      @value ? v = 1 : v = 0
      Gosu::draw_rect(x + 4 + (@h * v), y + 4, @h - 8, @h - 8, @value ? 0xff_ffffff : 0xff_000000, @z + 1)
    end

    def update(x = 0, y = 0)
      x += @x
      y += @y
      updateHover(x, y)
      @buttonColor = @hover ? LUIT.uiColorLight : LUIT.uiColor
      super
    end

    def button_down(id)
      if id == Gosu::MsLeft && @hover
        @value = !@value
        @holder.onClick(@id)
      end
    end
  end

  class List < LUITElement
    attr_reader :contents
    def initialize(holder, id, x, y, z, h, s = 10)
      super(holder, id, x, y, 50, h)
      @spaceing = s
      @contents = []
      @totalh = 0
      @focus = 0
      @scrollbar = VerticalSlider.new(self, "scroll", 0, 0, @h - 10)
    end

    def <<(item)
      @contents << item
      @totalh += item.h + @spaceing
      @w = @contents.max_by{|x| x.w}.w
    end

    def draw(x = 0, y = 0)
      x += @x
      y += @y
      prevh = 0
      @contents.each do |item|
        if !((prevh - @focus + item.h) <= 0 || (prevh - @focus) >= @h)
          item.draw(x + 30, y + prevh - @focus)
        end
        prevh += item.h + @spaceing
      end
      @scrollbar.draw(x, y)
    end

    def update(x = 0, y = 0)
      x += @x
      y += @y
      prevh = 0
      @contents.each do |item|
        if !((prevh - @focus + item.h) < 0 || (prevh - @focus) > @h)
          item.update(x + 30, y + prevh - @focus)
        end
        prevh += item.h + @spaceing
      end
      @scrollbar.update(x, y)
      if @totalh > @h
        v = @scrollbar.value / (@h - 10)
        @focus = (@totalh - @h) * v
      else
        @focus = 0
      end
    end
  end

  class Icon
    attr_reader :x, :y, :w, :h
    def initialize(path, x, y, z, w, h)
      @icon = Gosu::Image.new(path)
      @scalex = (w / (@icon.width))
      @scaley = (h / (@icon.height))
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def draw(x = 0, y = 0)
      @icon.draw(@x + x, @y + y, 1, @scalex, @scaley)
    end

    def update(x = 0, y = 0)
    end
  end

  @decimalValue = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  @romanNumeral = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I']
  def self.to_roman(number)
    return '0' if number == 0
    romanized = ''
    for index in 0...@decimalValue.length do
      while @decimalValue[index] <= number do
        romanized += @romanNumeral[index]
        number -= @decimalValue[index]
      end
    end
    return romanized
  end
end

#run file directly to run test window
if __FILE__ == $0
  class Test < Gosu::Window
    def initialize
      super(1000, 1000, false)

      LUIT.config(window: self)

      @LUITElements = []
      @LUITElements << LUIT::Button.new(self, 1, 0, 0, "Test")
      @LUITElements << LUIT::Button.new(self, 2, 111, 111, "Big button", 200, 70)
      @LUITElements << LUIT::Slider.new(self, 3, 300, 300, 300)
      @vslider = LUIT::VerticalSlider.new(self, 3, 250, 250, 300)
      @LUITElements << @vslider
      @LUITElements << LUIT::Toggle.new(self, 4, 500, 500)
      @LUITElements << LUIT::ClickArea.new(self, "click", 900, 900, 100, 100)
      @texter = LUIT::TextArea.new(self, "text", 300, 100, 32, 20)
      @LUITElements << @texter
      @LUITElements << LUIT::TextArea.new(self, "text2", 300, 200, 32, 20)
      @list = LUIT::List.new(self, "list", 0, 200, 300, 0)
      @LUITElements << @list
      20.times do
        @list << LUIT::Button.new(self, 1, 0, 0, "Test", 0, 50)
      end
      @font = Gosu::Font.new(30)
      @scanner = LUIT::ScannerInput.new(self, "dik")
    end

    def draw
      @LUITElements.each {|e| e.draw}
      @font.draw(LUIT::to_roman(@vslider.value), 600, 250, 2)
    end

    def update
      @LUITElements.each {|e| e.update}
      @scanner.scan
    end

    def button_down(id)
      case id
      when Gosu::KbSpace
        @list << LUIT::Button.new(self, 1, 0, 0, "Test", 0, 50)
      when Gosu::KbReturn
        puts @scanner.field.text
        @scanner.field.text = ""
      end
    end

    def onScan(text)
      puts text
      @scanner.scan
    end

    def onClick(id)
      puts id
      if id == "text"
        puts @texter.text
      end
    end

    def needs_cursor?
      return true
    end
  end
  Test.new.show
end
