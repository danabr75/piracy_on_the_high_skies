require_relative 'general_object.rb'

class Player < GeneralObject
  SPEED = 7
  MAX_ATTACK_SPEED = 3.0
  attr_accessor :cooldown_wait, :secondary_cooldown_wait, :attack_speed, :health, :armor, :x, :y, :rockets, :score, :time_alive, :bombs, :secondary_weapon, :grapple_hook_cooldown_wait
  MAX_HEALTH = 200

  SECONDARY_WEAPONS = %w[missile bomb]

  # def draw
  #   # Will generate error if class name is not listed on ZOrder
  #   @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering || Module.const_get("ZOrder::#{self.class.name}"))
  #   # @image.draw(@x - get_width / 2, @y - get_height / 2, get_draw_ordering)
  # end
  def initialize(scale, x, y)
    @scale = scale
    # image = Magick::Image::read("#{MEDIA_DIRECTORY}/spaceship.png").first.resize(0.3)
    # @image = Gosu::Image.new(image, :tileable => true)
    @image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship.png")
    @right_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_right.png")
    @left_image = Gosu::Image.new("#{MEDIA_DIRECTORY}/spaceship_left.png")
    # @beep = Gosu::Sample.new("#{MEDIA_DIRECTORY}/beep.wav")
    @x, @y = x, y
    @score = 0
    @cooldown_wait = 0
    @secondary_cooldown_wait = 0
    @grapple_hook_cooldown_wait = 0
    @attack_speed = 1
    # @attack_speed = 3
    # temp
    @health = 100
    # @health = 100000
    @armor = 0
    @rockets = 25
    # @rockets = 25000
    # @rocket_launcher = {}
    @bombs = 3
    # @bombs = 300
    @time_alive = 0
    @secondary_weapon = "missile"
    @turn_right = false
    @turn_left = false
    @image_width  = @image.width  * @scale
    @image_height = @image.height * @scale
    @image_size   = @image_width  * @image_height / 2
    @image_radius = (@image_width  + @image_height) / 4
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

  def move_left width
    @turn_left = true
    @x = [@x - get_speed, (get_width/3)].max
  end
  
  def move_right width
    @turn_right = true
    @x = [@x + get_speed, (width - (get_width/3))].min
  end
  
  def accelerate height
    @y = [@y - get_speed, (get_height/2)].max
  end
  
  def brake height
    @y = [@y + get_speed, height].min
  end


  def attack width, height, mouse_x = nil, mouse_y = nil
    return {
      projectiles: [Bullet.new(@scale, width, height, self, mouse_x, mouse_y, {side: 'left'}), Bullet.new(@scale, width, height, self, mouse_x, mouse_y, {side: 'right'})],
      cooldown: Bullet::COOLDOWN_DELAY
    }
  end

  def trigger_secondary_attack width, height, mouse_x, mouse_y
    return_projectiles = []
    if self.secondary_cooldown_wait <= 0 && self.get_secondary_ammo_count > 0
      results = self.secondary_attack(width, height, mouse_x, mouse_y)
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

  def secondary_attack width, height, mouse_x = nil, mouse_y = nil
    second_weapon = case @secondary_weapon
    when 'bomb'
      {
        projectiles: [Bomb.new(@scale, width, height, self, mouse_x, mouse_y)],
        cooldown: Bomb::COOLDOWN_DELAY
      }
    else
      if get_secondary_ammo_count > 1
        {
          projectiles: [Missile.new(@scale, width, height, self, mouse_x, mouse_y, {side: 'left'}), Missile.new(@scale, width, height, self, mouse_x, mouse_y, {side: 'right'})],
          cooldown: Missile::COOLDOWN_DELAY
        }
      else get_secondary_ammo_count == 1
        {
          projectiles: [Missile.new(@scale, width, height, self, mouse_x, mouse_y)],
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
  
  def update width, height, mouse_x = nil, mouse_y = nil, player = nil
    # puts "TEST HERE: width: #{get_width} and height: #{get_height}"
    @cooldown_wait -= 1              if @cooldown_wait > 0
    @secondary_cooldown_wait -= 1    if @secondary_cooldown_wait > 0
    @grapple_hook_cooldown_wait -= 1 if @grapple_hook_cooldown_wait > 0
    @time_alive += 1 if self.is_alive
  end

  # def collect_stars(stars)
  #   stars.reject! do |star|
  #     if Gosu.distance(@x, @y, star.x, star.y) < 35
  #       @score += 10
  #       @attack_speed = @attack_speed + 0.1
  #       @attack_speed = MAX_ATTACK_SPEED if @attack_speed > MAX_ATTACK_SPEED

  #       # stop that!
  #       # @beep.play
  #       true
  #     else
  #       false
  #     end
  #   end
  # end


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