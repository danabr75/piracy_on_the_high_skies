# I don't this this is used anymore

require_relative 'screen_map_fixed_object.rb'

class DumbProjectile < ScreenMapFixedObject
  attr_accessor :x, :y, :time_alive, :initial_angle
  # WARNING THESE CONSTANTS DON'T GET OVERRIDDEN BY SUBCLASSES. NEED GETTER METHODS
  COOLDOWN_DELAY = 50
  STARTING_SPEED = 3.0
  INITIAL_DELAY  = 0
  SPEED_INCREASE_FACTOR = 0.0
  DAMAGE = 5
  AOE = 0
  MAX_CURSOR_FOLLOW = 5 # Do we need this if we have a max speed?
  ADVANCED_HIT_BOX_DETECTION = false


  def get_image
   # puts "override get_image!"
    Gosu::Image.new("#{MEDIA_DIRECTORY}/question.png")
  end

  def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, object, initial_angle, current_map_pixel_x, current_map_pixel_y, map_pixel_width, map_pixel_height, tile_pixel_width, tile_pixel_height, options = {})
    @initial_angle = initial_angle
    options[:relative_object] = object
    @damage_increase = options[:damage_increase] || 1
    # if options[:debug] == true
    #  # puts "NEW DUMB PROJECTILE: X- #{object.x}"
    #  # puts "NEW DUMB PROJECTILE: y- #{object.y}"
    # end
    # raise "WHAT IS GOING ON HERE: #{scale}, #{object.x}, #{object.y}, #{screen_width}, #{screen_height}, #{width_scale}, #{height_scale}, #{location_x}, #{location_y}, #{map_width}, #{map_height},"
   # def initialize(width_scale, height_scale, screen_pixel_width, screen_pixel_height, current_map_pixel_x, current_map_pixel_y, current_map_tile_x, current_map_tile_y, map_pixel_width, map_pixel_height, tile_pixel_width, tile_pixel_height, options = {})
    super(width_scale, height_scale, screen_pixel_width, screen_pixel_height, current_map_pixel_x, current_map_pixel_y, nil, nil, map_pixel_width, map_pixel_height, tile_pixel_width, tile_pixel_height, options)
    @current_speed = self.class.get_max_speed * @scale
  end

  def draw_gl
  end

  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    @y -= @current_speed * scroll_factor
    @y > 0 && @y < @screen_pixel_height
  end


  def get_draw_ordering
    ZOrder::Projectile
  end

  def destructable?
    false
  end

  # def hit_object(object)
  #   return hit_objects([[object]])
  # end

  def hit_objects(object_groups)
    raise "MOVED TO PROJECTILE"
    # drops = []
    # points = 0
    # hit_object = false
    # killed = 0
    # object_groups.each do |group|
    #   group.each do |object|
    #     next if object.nil?
    #     break if hit_object
    #     if object.health <= 0
    #       next
    #     end
    #     hit_object = Gosu.distance(@current_map_pixel_x, @current_map_pixel_y, object.current_map_pixel_x, object.current_map_pixel_y) < self.get_radius + object.get_radius
    #    # puts "HIT OBJECT " if hit_object
    #     raise "test" if hit_object
    #     if hit_object
    #       if object.respond_to?(:health) && object.respond_to?(:take_damage)
    #         object.take_damage(self.class.get_damage * @damage_increase)
    #       end

    #       if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:drops)

    #         object.drops.each do |drop|
    #           drops << drop
    #         end
    #       end

    #       if object.respond_to?(:is_alive) && !object.is_alive && object.respond_to?(:get_points)
    #         killed += 1
    #         points = points + object.get_points
    #       end
    #     end
    #   end
    # end
    # @y = @off_screen if hit_object
    # collision_triggers if hit_object
    # return {drops: drops, point_value: points, killed: killed}
  end

  protected
  def self.get_damage
    self::DAMAGE
  end
  def self.get_aoe
    self::AOE
  end
  def self.get_cooldown_delay
    self::COOLDOWN_DELAY
  end
  def self.get_starting_speed
    self::STARTING_SPEED
  end
  def self.get_starting_speed
    self::STARTING_SPEED
  end
  def self.get_initial_delay
    self::INITIAL_DELAY
  end
  def self.get_speed_increase_factor
    self::SPEED_INCREASE_FACTOR
  end
  def self.get_max_cursor_follow
    self::MAX_CURSOR_FOLLOW
  end
  def self.get_advanced_hit_box_detection
    self::ADVANCED_HIT_BOX_DETECTION
  end
end