require_relative 'general_object.rb'

class Player < GeneralObject
  SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive, :bombs, :secondary_weapon, :grapple_hook_cooldown_wait
  MAX_HEALTH = 200

  SECONDARY_WEAPONS = %w[missile bomb]
  # Range goes clockwise around the 0-360 angle
  MISSILE_LAUNCHER_MIN_ANGLE = 75
  MISSILE_LAUNCHER_MAX_ANGLE = 105
  MISSILE_LAUNCHER_INIT_ANGLE = 90

  def get_image
    Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship.png")
  end

  def initialize(scale, x, y, screen_width, screen_height, options = {})
    super(scale, x, y, screen_width, screen_height, options)
    @right_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_right.png")
    @left_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_left.png")
    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @attack_speed = 1
    @health = 100
    @armor = 0
    # @rockets = 25
    @rockets = 250
    @bombs = 3
    @secondary_weapon = "missile"
    @turn_right = false
    @turn_left = false
  end


  def take_damage damage
    @health -= damage
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


  def decrement_secondary_ammo_count
    return case @secondary_weapon
    when 'bomb'
      self.bombs -= 1
    else
      self.rockets -= 1
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
    @y = [@y - get_speed, (get_height/2)].max
  end
  
  def brake
    @y = [@y + get_speed, @screen_height].min
  end


  def attack pointer
    return {
      projectiles: [
        Bullet.new(@scale, @screen_width, @screen_height, self, {side: 'left',  relative_object: self}),
        Bullet.new(@scale, @screen_width, @screen_height, self, {side: 'right', relative_object: self})
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
        self.decrement_secondary_ammo_count
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
    second_weapon = case @secondary_weapon
    when 'bomb'
      {
        projectiles: [Bomb.new(@scale, @screen_width, @screen_height, self, mouse_x, mouse_y)],
        cooldown: Bomb::COOLDOWN_DELAY
      }
    else
      if get_secondary_ammo_count > 1
        {
          projectiles: [
            Missile.new(@scale, @screen_width, @screen_height, self, pointer.x - @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'left',  relative_object: self}),
            Missile.new(@scale, @screen_width, @screen_height, self, pointer.x + @image_width_half, pointer.y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE, {side: 'right', relative_object: self})
            ],
          cooldown: Missile::COOLDOWN_DELAY
        }
        # {
        #   projectiles: [
        #     Missile.new(@scale, @screen_width, @screen_height, self, mouse_x, mouse_y, MISSILE_LAUNCHER_MIN_ANGLE, MISSILE_LAUNCHER_MAX_ANGLE, MISSILE_LAUNCHER_INIT_ANGLE)
        #     ],
        #   cooldown: Missile::COOLDOWN_DELAY
        # }
      else get_secondary_ammo_count == 1
        {
          projectiles: [Missile.new(@scale, @screen_width, @screen_height, self, mouse_x, mouse_y, {relative_object: self})],
          cooldown: Missile::COOLDOWN_DELAY
        }
      end
    end
    return second_weapon
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