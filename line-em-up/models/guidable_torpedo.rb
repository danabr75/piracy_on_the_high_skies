# require_relative 'general_object.rb'
# class GuidableTorpedo < GeneralObject
#   attr_reader :x, :y, :time_alive
#   COOLDOWN_DELAY = 30
#   MAX_SPEED      = 25
#   # STARTING_SPEED = 0.0
#   # INITIAL_DELAY  = 2
#   # SPEED_INCREASE_FACTOR = 0.5
#   DAMAGE = 0
  
#   MAX_CURSOR_FOLLOW = 15

#   def initialize(object)

#     image = Magick::Image::read("#{MEDIA_DIRECTORY}/missile.png").first.resize(0.3)
#     @image = Gosu::Image.new(image, :tileable => true)

#     @x = object.get_x - (object.get_width / 2)
#     @y = object.get_y

#     # @x = mouse_x
#     # @y = mouse_y
#     # @time_alive = 0
#   end

#   def draw
#     # puts Gosu.milliseconds
#     # puts @animation.size
#     # puts 100 % @animation.size
#     # puts "Gosu.milliseconds / 100 % @animation.size: #{Gosu.milliseconds / 100 % @animation.size}"
#     # img.draw(@x, @y, ZOrder::Projectile, :add)
#     puts "11: #{@x} and #{@y}"
#     @image.draw(@x, @y, ZOrder::Projectile)
#     # img.draw_rect(@x, @y, 25, 25, @x + 25, @y + 25, :add)
#   end
  
#   def update mouse_x = nil, mouse_y = nil
#     # mouse_x = @mouse_start_x
#     # mouse_y = @mouse_start_y
#     # if @time_alive > INITIAL_DELAY
#     #   new_speed = STARTING_SPEED + (@time_alive * SPEED_INCREASE_FACTOR)
#     #   new_speed = MAX_SPEED if new_speed > MAX_SPEED
#     #   @y -= new_speed
#     # end

#     # Cursor is left of the missle, missile needs to go left. @x needs to get smaller. @x is greater than mouse_x
#     if @x > mouse_x
#       difference = @x - mouse_x
#       if difference > MAX_CURSOR_FOLLOW
#         difference = MAX_CURSOR_FOLLOW
#       end
#       @x = @x - difference
#     else
#       # Cursor is right of the missle, missile needs to go right. @x needs to get bigger. @x is smaller than mouse_x
#       difference = mouse_x - @x
#       if difference > MAX_CURSOR_FOLLOW
#         difference = MAX_CURSOR_FOLLOW
#       end
#       @x = @x + difference
#     end

#     if @y > mouse_y
#       difference = @y - mouse_y
#       if difference > MAX_CURSOR_FOLLOW
#         difference = MAX_CURSOR_FOLLOW
#       end
#       @y = @y - difference
#     else
#       # Cursor is right of the missle, missile needs to go right. @y needs to get bigger. @y is smaller than mouse_y
#       difference = mouse_y - @y
#       if difference > MAX_CURSOR_FOLLOW
#         difference = MAX_CURSOR_FOLLOW
#       end
#       @y = @y + difference
#     end

#     # Return false when out of screen (gets deleted then)
#     # @time_alive += 1
#   end


#   def hit_objects(objects)
#     drops = []
#     objects.each do |object|
#       if Gosu.distance(@x, @y, object.x, object.y) < 30
#         # Missile destroyed
#         # @y = -100
#         if object.respond_to?(:health) && object.respond_to?(:take_damage)
#           object.take_damage(DAMAGE)
#         end

#         if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)
#           puts "CALLING THE DROP"
#           object.drops.each do |drop|
#             drops << drop
#           end
#         end

#       end
#     end
#     return drops
#   end


#   def hit_object(object)
#     return_value = nil
#     if Gosu.distance(@x, @y, object.x, object.y) < 30
#       @y = -50
#       return_value = DAMAGE
#     else
#       return_value = 0
#     end
#     return return_value
#   end


# end