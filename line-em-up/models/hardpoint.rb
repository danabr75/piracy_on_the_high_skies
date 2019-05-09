require_relative 'general_object.rb'
require 'gosu'

require 'opengl'
require 'glut'


include OpenGL
include GLUT

# Not intended to be overridden
class Hardpoint < GeneralObject
  attr_accessor :x, :y
  attr_accessor :group_number, :y_offset, :x_offset, :main_weapon, :image_hardpoint, :image_hardpoint_width_half, :image_hardpoint_height_half


  # MISSILE_LAUNCHER_MIN_ANGLE = 75
  # MISSILE_LAUNCHER_MAX_ANGLE = 105
  # MISSILE_LAUNCHER_INIT_ANGLE = 90

  def initialize(scale, x, y, screen_width, screen_height, group_number, x_offset, y_offset, weapon_klass, options = {})
    puts "GHARDPOINT INIT: #{y_offset}"
    @group_number = group_number
    @x_offset = x_offset# * scale
    @y_offset = y_offset# * scale
    super(scale, x + @x_offset, y + @y_offset, screen_width, screen_height, options)
    @main_weapon = nil
    @assigned_weapon_class = weapon_klass
    @drawable_items_near_self = []

    @image_hardpoint = weapon_klass.get_image_hardpoint
    @image_hardpoint_width_half = @image_hardpoint.width  / 2
    @image_hardpoint_height_half = @image_hardpoint.height  / 2

  end



  def stop_attack
    # puts "HARDPOINT STOP ATTACK"
    @main_weapon.deactivate if @main_weapon
  end

  def attack pointer, opts = {}
    puts "HARDPOINT ATTACK"
    attack_projectile = nil
    if @main_weapon.nil?
      # options = {damage_increase: @damage_increase, relative_y_padding: @image_height_half}
      options = {}
      options[:damage_increase] = opts[:damage_increase] if opts[:damage_increase]
      @main_weapon = @assigned_weapon_class.new(@scale, @screen_width, @screen_height, self, options)
      @drawable_items_near_self << @main_weapon
      attack_projectile = @main_weapon.attack(pointer)
    else
      @main_weapon.active = true if @main_weapon.active == false
      @drawable_items_near_self << @main_weapon
      attack_projectile = @main_weapon.attack(pointer)
    end
    if attack_projectile
      return {
        projectiles: [attack_projectile],
        cooldown: @assigned_weapon_class::COOLDOWN_DELAY
      }
    else
      return nil
    end
  end

  def get_x
    @x
  end

  def get_y
    @y
  end

  def get_draw_ordering
    ZOrder::Hardpoint
  end

  def draw
    @drawable_items_near_self.reject! { |item| item.draw }
    @image_hardpoint.draw(@x - @image_hardpoint_width_half, @y - @image_hardpoint_height_half, get_draw_ordering, @scale, @scale)
  end

  def draw_gl
    @drawable_items_near_self.reject! { |item| item.draw_gl }
  end


  def update mouse_x = nil, mouse_y = nil, player = nil, scroll_factor = 1
    # puts "HARDPOINT X offset: #{@x_offset}"
    # puts "HARDPOINT Y offset: #{@y_offset}"
    @x = player.x + @x_offset# * @scale
    @y = player.y + @y_offset# * @scale
    # Update list of weapons for special cases like beans. Could iterate though an association in the future.
    @main_weapon.update(mouse_x, mouse_y, self, scroll_factor) if @main_weapon
    # @cooldown_wait -= 1              if @cooldown_wait > 0
    # @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    # @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    # @time_alive += 1 if self.is_alive
  end

end