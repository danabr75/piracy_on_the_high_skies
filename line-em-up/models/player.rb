require_relative 'general_object.rb'
require_relative 'rocket_launcher_pickup.rb'

class Player < GeneralObject
  SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive

  attr_accessor :bombs, :secondary_weapon, :grapple_hook_cooldown_wait, :damage_reduction, :boost_increase, :damage_increase, :kill_count
  attr_accessor :special_attack
  MAX_HEALTH = 200

  SECONDARY_WEAPONS = [RocketLauncherPickup::NAME] + %w[bomb]
  # Range goes clockwise around the 0-360 angle
  MISSILE_LAUNCHER_MIN_ANGLE = 75
  MISSILE_LAUNCHER_MAX_ANGLE = 105
  MISSILE_LAUNCHER_INIT_ANGLE = 90

  SPECIAL_POWER = 'laser'
  SPECIAL_POWER_KILL_MAX = 50

  def get_kill_count_max
    self.class::SPECIAL_POWER_KILL_MAX
  end

  def ready_for_special?
    @kill_count >= get_kill_count_max
  end

  def special_attack object_groups
    # Fire special attack.
    @kill_count = 0
    projectiles = []
    object_groups.each do |group|
      group.each do |object|
        next if object.nil?
          projectiles << Missile.new(@scale, @screen_width, @screen_height, self, object.x, object.y, nil, nil, nil, {damage_increase: @damage_increase})
      end
    end
    return projectiles
  end


  def special_attack_2
    # Fire special attack.
    @kill_count = 0
    projectiles = []
    # object_groups.each do |group|
    #   group.each do |object|
    #     next if object.nil?
    #       projectiles << Missile.new(@scale, @screen_width, @screen_height, self, object.x, object.y, nil, nil, nil, {damage_increase: @damage_increase})
    #   end
    # end

    r = 10 * @scale
    theta = 0
    count_max = 360
    max_passes = 3
    pass_count = 0
    theta = 0
    # Need a projectile queue system?
    while theta < count_max
      x  =  @x + r * Math.cos(theta)
      y  =  @y + r * Math.sin(theta)
      if y < @y

        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, x, y, nil, nil, nil, {damage_increase: @damage_increase})

      end
      theta += 5
    end
    # where r is the radius of the circle, and h,k are the coordinates of the center.

    return projectiles
  end


  # Rocket Launcher, Rocket launcher, Cannon, Cannon, Bomb Launcher
  HARD_POINTS = 12

  def add_kill_count kill_count
    if @kill_count + kill_count > get_kill_count_max
      @kill_count = get_kill_count_max
    else
      @kill_count += kill_count
    end
  end

  def add_hard_point hard_point
    @hard_point_items << hard_point
    trigger_hard_point_load
  end

  def trigger_hard_point_load
    @rocket_launchers, @bomb_launchers, @cannon_launchers = [0, 0, 0]
    count = 0
    # puts "RUNNING ON: #{@hard_point_items}"
    @hard_point_items.each do |hard_point|
      break if count == HARD_POINTS
      case hard_point
      when 'bomb_launcher'
        @bomb_launchers += 1
      when RocketLauncherPickup::NAME
        # puts "INCREASTING ROCKET LAUNCHER: #{RocketLauncherPickup::NAME}"
        @rocket_launchers += 1
      when 'cannon_launcher'
        @cannon_launchers += 1
      else
        "Raise should never get here. hard_point: #{hard_point}"
      end
      count += 1
    end
  end

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship.png")
  end

  def initialize(scale, x, y, screen_width, screen_height, options = {})
    super(scale, x, y, screen_width, screen_height, options)
    # Top of screen
    @min_moveable_height = options[:min_moveable_height] || 0
    # Bottom of the screen
    @max_movable_height = options[:max_movable_height] || screen_height
    @right_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_right.png")
    @left_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_left.png")
    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @attack_speed = 1
    # @attack_speed = 3
    @health = 100.0
    @armor = 0
    @rockets = 50
    # @rockets = 250
    @bombs = 3
    @secondary_weapon = RocketLauncherPickup::NAME
    @turn_right = false
    @turn_left = false

    @hard_point_items = [RocketLauncherPickup::NAME, 'cannon_launcher', 'cannon_launcher', 'bomb_launcher']
    @rocket_launchers = 0
    @bomb_launchers   = 0
    @cannon_launchers = 0
    trigger_hard_point_load
    @damage_reduction = options[:handicap] ? options[:handicap] : 1
    invert_handicap = 1 - options[:handicap]
    @boost_increase = invert_handicap > 0 ? 1 + (invert_handicap * 1.25) : 1
    @damage_increase = invert_handicap > 0 ? 1 + (invert_handicap) : 1
    @kill_count = 0
  end


  def take_damage damage
    @health -= damage * @damage_reduction
  end

  def toggle_secondary
    current_index = SECONDARY_WEAPONS.index(@secondary_weapon)
    if current_index == SECONDARY_WEAPONS.count - 1
      @secondary_weapon = SECONDARY_WEAPONS[0]
    else
      @secondary_weapon = SECONDARY_WEAPONS[current_index + 1]
    end
  end

  def get_secondary_ammo_count
    return case @secondary_weapon
    when 'bomb'
      self.bombs
    else
      self.rockets
    end
  end


  def decrement_secondary_ammo_count count = 1
    return case @secondary_weapon
    when 'bomb'
      self.bombs -= count
    else
      self.rockets -= count
    end
  end

  def get_secondary_name
    return case @secondary_weapon
    when 'bomb'
      'Bomb'
    else
      'Rocket'
    end
  end

  def get_x
    @x
  end
  def get_y
    @y
  end

  def is_alive
    health > 0
  end

  def get_speed
    (SPEED * @scale).round
  end

  def move_left
    @turn_left = true
    @x = [@x - get_speed, (get_width/3)].max
  end
  
  def move_right
    @turn_right = true
    @x = [@x + get_speed, (@screen_width - (get_width/3))].min
  end
  
  def accelerate
    # # Top of screen
    # @min_moveable_height = options[:min_moveable_height] || 0
    # # Bottom of the screen
    # @max_movable_height = options[:max_movable_height] || screen_height

    @y = [@y - get_speed, @min_moveable_height + (get_height/2)].max
  end
  
  def brake
    @y = [@y + get_speed, @max_movable_height - (get_height/2)].min
  end


  def attack pointer
    return {
      projectiles: [
        Bullet.new(@scale, @screen_width, @screen_height, self, {side: 'left', damage_increase: @damage_increase}),
        Bullet.new(@scale, @screen_width, @screen_height, self, {side: 'right', damage_increase: @damage_increase})
      ],
      cooldown: Bullet::COOLDOWN_DELAY
    }
  end

  def trigger_secondary_attack pointer
    return_projectiles = []
    if self.secondary_cooldown_wait <= 0 && self.get_secondary_ammo_count > 0
      results = self.secondary_attack(pointer)
      projectiles = results[:projectiles]
      cooldown = results[:cooldown]
      self.secondary_cooldown_wait = cooldown.to_f.fdiv(self.attack_speed)

      projectiles.each do |projectile|
        return_projectiles.push(projectile)
      end
    end
    return return_projectiles
  end

  # def toggle_state_secondary_attack
  #   second_weapon = case @secondary_weapon
  #   when 'bomb'
  #   else
  #   end
  #   return second_weapon
  # end

  def secondary_attack pointer
    projectiles = []
    cooldown = 0
    case @secondary_weapon
    when 'bomb'
      projectiles << Bomb.new(@scale, @screen_width, @screen_height, self, pointer.x, pointer.y, nil, nil, nil, {damage_increase: @damage_increase})
      cooldown = Bomb::COOLDOWN_DELAY
    when RocketLauncherPickup::NAME
      # NEEED TO DECRETMENT AMMO BASED OFF OF LAUNCHERS!!!!!!!!!!!
      # puts "ROCKET LAUNCHERS: #{@rocket_launchers}"
      cooldown = Missile::COOLDOWN_DELAY
      if get_secondary_ammo_count == 1 && @rocket_launchers > 0 || @rocket_launchers == 1
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {damage_increase: @damage_increase})
      elsif get_secondary_ammo_count == 2 && @rocket_launchers >= 2 || @rocket_launchers == 2
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase})
      elsif get_secondary_ammo_count == 3 && @rocket_launchers >= 3 || @rocket_launchers == 3
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase})
      elsif get_secondary_ammo_count == 4 && @rocket_launchers >= 4 || @rocket_launchers == 4
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE + 15, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE - 15, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase})

        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half / 2, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE + 5, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase,  relative_x_padding:  (@image_width_half / 2) })
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half / 2, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE - 5, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase, relative_x_padding: -(@image_width_half / 2) })
      elsif get_secondary_ammo_count == 5 && @rocket_launchers >= 5 || @rocket_launchers >= 5
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE + 15, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase})
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE - 15, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase})

        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half / 2, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE + 5, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left', damage_increase: @damage_increase,  relative_x_padding:  (@image_width_half / 2) })
        projectiles << Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half / 2, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE - 5, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', damage_increase: @damage_increase, relative_x_padding: -(@image_width_half / 2) })
      else
        raise "Should never get here: @secondary_weapon: #{@secondary_weapon} for @rocket_launchers: #{@rocket_launchers} and get_secondary_ammo_count: #{get_secondary_ammo_count}"
      end
    end
    decrement_secondary_ammo_count projectiles.count
    return {projectiles: projectiles, cooldown: cooldown}
  end

  def get_draw_ordering
    ZOrder::Player
  end

  def draw
    if @turn_right
      image = @right_image
    elsif @turn_left
      image = @left_image
    else
      image = @image
    end
    # super
    image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering, @scale, @scale)
    @turn_right = false
    @turn_left = false
  end
  
  def update mouse_x = nil, mouse_y = nil, player = nil
    @cooldown_wait -= 1              if @cooldown_wait > 0
    @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    @time_alive += 1 if self.is_alive
  end

  def collect_pickups(pickups)
    pickups.reject! do |pickup|
      if Gosu.distance(@x, @y, pickup.x, pickup.y) < ((self.get_radius) + (pickup.get_radius)) * 1.2 && pickup.respond_to?(:collected_by_player)
        pickup.collected_by_player(self)
        if pickup.respond_to?(:get_points)
          self.score += pickup.get_points
        end
        # stop that!
        # @beep.play
        true
      else
        false
      end
    end
  end


end