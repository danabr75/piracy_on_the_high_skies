# A simple "Triangle Game" that allows you to move a Roguelike '@' around the
# window (and off of it). This is a working example on MacOS 10.12 as of Dec 16, 2017.
# This combines some of the Ruby2D tutorial code with keypress management
# that actually works.
# 
# Keys: hjkl: movement, q: quit
# 
# To run: ruby triangle-game.rb after installing the Simple2D library and Ruby2D Gem.
#
# Author: Douglas P. Fields, Jr.
# E-mail: symbolics@lisp.engineer
# Site: https://symbolics.lisp.engineer/
# Copyright 2017 Douglas P. Fields, Jr.
# License: The MIT License

# require 'gosu'

# Encoding: UTF-8

# The tutorial game over a landscape rendered with OpenGL.
# Basically shows how arbitrary OpenGL calls can be put into
# the block given to Window#gl, and that Gosu Images can be
# used as textures using the gl_tex_info call.

# require 'rubygems'
require 'gosu'

CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
MEDIA_DIRECTORY   = File.expand_path('../', __FILE__) + "/media"

# ONLY ENABLE FOR WINDOWS COMPILATION
# Place opengl lib in lib library
# Replace the meths list iteration with the following (added rescue blocks):
  # meths.each do |mn|
  #   define_singleton_method(mn) do |*args,&block|
  #     begin
  #       implementation.send(mn, *args, &block)
  #     rescue
  #     end
  #   end
  #   define_method(mn) do |*args,&block|
  #     begin
  #       implementation.send(mn, *args, &block)
  #     rescue
  #     end
  #   end
  #   private mn
  # end
# For WINDOWS - using local lip
# require_relative 'lib/opengl.rb'
# FOR Linux\OSX - using opengl gem
require 'opengl'

Dir["#{CURRENT_DIRECTORY}/lib/*.rb"].each { |f| require f }
Dir["#{CURRENT_DIRECTORY}/models/*.rb"].each { |f| require f }

# require_relative 'media'
# Dir["/path/to/directory/*.rb"].each {|file| require file }
# 
# exit if Object.const_defined?(:Ocra) #allow ocra to create an exe without executing the entire script


WIDTH, HEIGHT = 640, 480

RESOLUTIONS = [[640, 480], [800, 600], [960, 720], [1024, 768], [1280, 960], [1400, 1050], [1440, 1080], [1600, 1200], [1856, 1392], [1920, 1440], [2048, 1536]]
# RESOLUTIONS = [[640, 480], [800, 600], [960, 720], [1024, 768]]
# WIDTH, HEIGHT = 1080, 720

class GameWindow < Gosu::Window
  attr_accessor :width, :height, :block_all_controls

  # Switch button downs to this method
  def button_down(id)
    # puts "HERE: #{id.inspect}"
    # super(id)
    if id == Gosu::MsLeft && @menu_open && @menu
      @menu.clicked
    end
  end

  def self.reset(window, options = {})
    window = GameWindow.new(window.width, window.height, window.fullscreen?, {block_controls_until_button_up: true, debug: options[:debug]}).show
  end


  def self.start width = nil, height = nil, fullscreen = false, options = {}
    # window = GameWindow.new.show
    GameWindow.new(width, height, fullscreen, options).show
  end

# When fullscreen, try to match window with screen resolution
# .screen_height ⇒ Integer
# The height (in pixels) of the user's primary screen.
# .screen_width ⇒ Integer
# The width (in pixels) of the user's primary screen.

  def self.fullscreen(window)
    window.fullscreen = !window.fullscreen?
  end

  def self.resize(window, width, height, fullscreen)
    window = GameWindow.new(width, height).show
    window.fullscreen = fullscreen
  end

  def self.find_index_of_current_resolution width, height
    current_index = nil
    counter = 0
    RESOLUTIONS.each do |resolution|
      break if current_index && current_index > 0
      current_index = counter if resolution[0] == width && resolution[1] == height
      counter += 1
    end
    return current_index
  end

  def self.up_resolution(window)
    # puts "UP RESLUTION"
    index = find_index_of_current_resolution(window.width, window.height)
    # puts "FOUND INDEX: #{index}"
    if index == RESOLUTIONS.count - 1
      # Max resolution, do nothing
    else
      # window.width = RESOLUTIONS[index + 1][0]
      # window.height = RESOLUTIONS[index + 1][1]
      width = RESOLUTIONS[index + 1][0]
      height = RESOLUTIONS[index + 1][1]
      # puts "UPPING TO #{width} x #{height}"
      window = GameWindow.new(width, height, {block_resize: true}).show
    end
  end

  def self.down_resolution(window)
    index = find_index_of_current_resolution(window.width, window.height)
    if index == 0
      # Min resolution, do nothing
    else
      # window.width = RESOLUTIONS[index - 1][0]
      # window.height = RESOLUTIONS[index - 1][1]
      width = RESOLUTIONS[index - 1][0]
      height = RESOLUTIONS[index - 1][1]
      window = GameWindow.new(width, height, {block_resize: true}).show
    end
  end

  def initialize width = nil, height = nil, fullscreen = false, options = {}
    @block_all_controls = !options[:block_controls_until_button_up].nil? && options[:block_controls_until_button_up] == true ? true : false
    @debug = options[:debug]
    # GameWindow.fullscreen(self) if fullscreen
    @start_fullscreen = fullscreen
    @center_ui_y = 0
    @center_ui_x = 0

    @width  = width || WIDTH
    @height = height || HEIGHT

    reset_center_font_ui_y

    index = GameWindow.find_index_of_current_resolution(self.width, self.height)
    if index == 0
      @scale = 1
    else
      original_width, original_height = RESOLUTIONS[0]
      width_scale = @width / original_width.to_f
      height_scale = @height / original_height.to_f
      @scale = (width_scale + height_scale) / 2
    end
    super(@width, @height)
    
    @game_pause = false
    @game_pause = false
    @menu_open = false
    @menu = nil
    @can_open_menu = true
    @can_pause = true
    @can_resize = !options[:block_resize].nil? && options[:block_resize] == true ? false : true
    @can_toggle_secondary = true
    @can_toggle_fullscreen_a = true
    @can_toggle_fullscreen_b = true

    self.caption = "OpenGL Integration"
    
    @gl_background = GLBackground.new
    
    @player = Player.new(@scale, @width / 2, @height / 2)
    @grappling_hook = nil
    
    @buildings = Array.new
    @projectiles = Array.new
    @enemy_projectiles = Array.new
    @enemy_destructable_projectiles = Array.new
    @pickups = Array.new

    @enemies = Array.new
    @enemies_random_spawn_timer = 100
    # @enemies_random_spawn_timer = 5
    @enemies_spawner_counter = 0
    # @enemies_spawner_counter = 5

    @max_enemy_count = 30
    @enemies_killed = 0
    
    @font = Gosu::Font.new(20)
    @max_enemies = 4

    @pointer = Cursor.new(@scale)
    @ui_y = 0
    @footer_bar = FooterBar.new(@scale, @width, @height)
    reset_font_ui_y
  end

  def button_up id
    @block_all_controls = false
    # Grappling hook always active
    # if (id == Gosu::MS_RIGHT) && @player.is_alive
    #   @grappling_hook.deactivate if @grappling_hook
    # end

    if (id == Gosu::KB_P)
      @can_pause = true
    end
    if (id == Gosu::KB_TAB)
      @can_toggle_secondary = true
    end

    if id == Gosu::KB_RETURN
      @can_toggle_fullscreen_a = true
    end
    if id == Gosu::KB_RIGHT_META
      @can_toggle_fullscreen_b = true
    end
    if id == Gosu::KB_MINUS
      @can_resize = true
    end
    if id == Gosu::KB_EQUALS
      @can_resize = true
    end
  end

  def get_center_font_ui_y
    return_value = @center_ui_y
    @center_ui_y += 50 
    return return_value
  end

  def get_center_font_ui_x
    return @center_ui_x
  end

  def reset_center_font_ui_y
    @center_ui_y = @height  / 2 - 100
    @center_ui_x = @width / 2 - 100
  end

  def update
    if @start_fullscreen
      @start_fullscreen = false
      GameWindow.fullscreen(self)
    end
    reset_center_font_ui_y
    @menu.update if @menu
    if !@block_all_controls
      if Gosu.button_down?(Gosu::KbEscape) && @can_open_menu
        @menu_open = true
        @can_open_menu = false
        @menu = Menu.new(self)
        @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/exit.png", false), get_center_font_ui_x, get_center_font_ui_y, 1, lambda { self.close }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/exit_hover.png", false))
        @menu.add_item(Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/resume.png", false), get_center_font_ui_x, get_center_font_ui_y, 1, lambda { @menu_open = false; @menu = nil; @can_open_menu = true; }, Gosu::Image.new(self, "#{MEDIA_DIRECTORY}/resume.png", false))
        # close!
      end
      if Gosu.button_down?(Gosu::KB_M)
        GameWindow.reset(self, {debug: @debug})
      end

      if Gosu.button_down?(Gosu::KB_RIGHT_META) && Gosu.button_down?(Gosu::KB_RETURN) && @can_toggle_fullscreen_a && @can_toggle_fullscreen_b
        @can_toggle_fullscreen_a = false
        @can_toggle_fullscreen_b = false
        GameWindow.fullscreen(self)
      end


      if Gosu.button_down?(Gosu::KB_P) && @can_pause
        @can_pause = false
        @game_pause = !@game_pause
      end

      if Gosu.button_down?(Gosu::KB_O) && @can_resize
        @can_resize = false
        GameWindow.resize(self, 1920, 1080, false)
      end

      if Gosu.button_down?(Gosu::KB_MINUS) && @can_resize
        @can_resize = false
        GameWindow.down_resolution(self)
      end
      if Gosu.button_down?(Gosu::KB_EQUALS) && @can_resize
        @can_resize = false
        GameWindow.up_resolution(self)
      end


      if Gosu.button_down?(Gosu::KB_TAB) && @can_toggle_secondary
        @can_toggle_secondary = false
        @player.toggle_secondary
      end

      if @player.is_alive && !@game_pause && !@menu_open
        @player.update(@width, @height)
        @player.move_left(@width)  if Gosu.button_down?(Gosu::KB_LEFT)  || Gosu.button_down?(Gosu::GP_LEFT)    || Gosu.button_down?(Gosu::KB_A)
        @player.move_right(@width) if Gosu.button_down?(Gosu::KB_RIGHT) || Gosu.button_down?(Gosu::GP_RIGHT)   || Gosu.button_down?(Gosu::KB_D)
        @player.accelerate(@height) if Gosu.button_down?(Gosu::KB_UP)    || Gosu.button_down?(Gosu::GP_UP)      || Gosu.button_down?(Gosu::KB_W)
        @player.brake(@height)      if Gosu.button_down?(Gosu::KB_DOWN)  || Gosu.button_down?(Gosu::GP_DOWN)    || Gosu.button_down?(Gosu::KB_S)

        if Gosu.button_down?(Gosu::MS_RIGHT)
          if @grappling_hook == nil && @player.grapple_hook_cooldown_wait <= 0
            @grappling_hook = GrapplingHook.new(@scale, @player, self.mouse_x, self.mouse_y)
          end
        end

        if Gosu.button_down?(Gosu::MS_LEFT)
          @projectiles = @projectiles + @player.trigger_secondary_attack(@width, @height, self.mouse_x, self.mouse_y)
        end

        if Gosu.button_down?(Gosu::KB_SPACE)
          if @player.cooldown_wait <= 0
            results = @player.attack(@width, @height, self.mouse_x, self.mouse_y)
            projectiles = results[:projectiles]
            cooldown = results[:cooldown]
            @player.cooldown_wait = cooldown.to_f.fdiv(@player.attack_speed)

            projectiles.each do |projectile|
              @projectiles.push(projectile)
            end
          end
        end


        @player.collect_pickups(@pickups)

        @enemy_projectiles.each do |projectile|
          projectile.hit_object(@player)
        end
        @enemy_destructable_projectiles.each do |projectile|
          projectile.hit_object(@player)
        end


        @grappling_hook.collect_pickups(@player, @pickups) if @grappling_hook && @grappling_hook.active
      end

      if !@game_pause && !@menu_open

        @projectiles.each do |projectile|
          results = projectile.hit_objects([@enemies, @buildings, @enemy_destructable_projectiles])
          
          @pickups = @pickups + results[:drops]
          @player.score += results[:point_value]
          @enemies_killed += results[:killed]
        end


        
        
        @buildings.reject! { |building| !building.update(@width, @height) }

        if @player.is_alive && @grappling_hook
          grap_result = @grappling_hook.update(@width, @height, @player)
          @grappling_hook = nil if !grap_result
        end

        @pickups.reject! { |pickup| !pickup.update(@width, @height, self.mouse_x, self.mouse_y) }

        @projectiles.reject! { |projectile| !projectile.update(@width, @height, self.mouse_x, self.mouse_y) }

        @enemy_projectiles.reject! { |projectile| !projectile.update(@width, @height, self.mouse_x, self.mouse_y) }
        @enemy_destructable_projectiles.reject! { |projectile| !projectile.update(@width, @height, self.mouse_x, self.mouse_y) }
        @enemies.reject! { |enemy| !enemy.update(@width, @height, nil, nil, @player) }


        @gl_background.scroll
        
        @buildings.push(Building.new(@scale)) if rand(100) == 0

        # Temp
        # @enemies.push(MissileBoat.new(@scale, @width, @height)) if rand(10) == 0

        if @player.is_alive && rand(@enemies_random_spawn_timer) == 0 && @enemies.count <= @max_enemies
          (0..(@enemies_spawner_counter / 2).round).each do |count|
            @enemies.push(EnemyPlayer.new(@scale, @width, @height)) if @enemies.count <= @max_enemy_count
          end
        end
        if @player.time_alive % 500 == 0
          @max_enemies += 1
        end
        if @player.time_alive % 1000 == 0 && @enemies_random_spawn_timer > 5
          @enemies_random_spawn_timer -= 5
        end
        # temp
        if @player.time_alive % 200 == 0
          (0..(@enemies_spawner_counter / 4).round).each do |count|
            @enemies.push(MissileBoat.new(@scale, @width, @height)) if @enemies.count <= @max_enemy_count
          end
        end
        if @player.time_alive % 5000 == 0
          @enemies_spawner_counter += 1
        end

        if @player.time_alive % 1000 == 0 && @player.time_alive > 0
          @player.score += 100
        end


        # Move to enemy mehtods
        @enemies.each do |enemy|
          if enemy.cooldown_wait <= 0
            results = enemy.attack(@width, @height, @player)

            projectiles = results[:projectiles]
            cooldown = results[:cooldown]
            enemy.cooldown_wait = cooldown.to_f.fdiv(enemy.attack_speed)

            projectiles.each do |projectile|
              if projectile.destructable?
                @enemy_destructable_projectiles.push(projectile)
              else
                @enemy_projectiles.push(projectile)
              end
            end
          end
        end
      end
    end
  end

  def draw
    @menu.draw if @menu
    @footer_bar.draw(@player)
    # @pointer.draw(self.mouse_x, self.mouse_y) if @grappling_hook.nil? || !@grappling_hook.active
    @pointer.draw(self.mouse_x, self.mouse_y)# if @grappling_hook.nil? || !@grappling_hook.active

    @player.draw() if @player.is_alive
    @grappling_hook.draw(@player) if @player.is_alive && @grappling_hook
    if !@menu && !@player.is_alive
      @font.draw("You are dead!", @width / 2 - 50, @height / 2 - 55, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press ESC to quit", @width / 2 - 50, @height / 2 - 40, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press M to Restart", @width / 2 - 50, @height / 2 - 25, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
    @font.draw("Paused", @width / 2 - 50, @height / 2 - 25, ZOrder::UI, 1.0, 1.0, 0xff_ffff00) if @game_pause
    @enemies.each { |enemy| enemy.draw() }
    @projectiles.each { |projectile| projectile.draw() }
    @enemy_projectiles.each { |projectile| projectile.draw() }
    @enemy_destructable_projectiles.each { |projectile| projectile.draw() }
    # @stars.each { |star| star.draw }
    @pickups.each { |pickup| pickup.draw() }
    @buildings.each { |building| building.draw() }
    @font.draw("Score: #{@player.score}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    @font.draw("Level: #{@enemies_spawner_counter + 1}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    @font.draw("Enemies Killed: #{@enemies_killed}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    if @debug
      # @font.draw("Attack Speed: #{@player.attack_speed.round(2)}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Health: #{@player.health}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Armor: #{@player.armor}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      # @font.draw("Rockets: #{@player.rockets}", 10, 70, ZOrder::UI, 1.0, 1.0, 0xff_ffff00) if @player.secondary_weapon == 'missile'
      # @font.draw("Bombs: #{@player.bombs}", 10, 70, ZOrder::UI, 1.0, 1.0, 0xff_ffff00) if @player.secondary_weapon == 'bomb'
      @font.draw("Weapon: #{@player.get_secondary_name}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Rockets: #{@player.rockets}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Bombs: #{@player.bombs}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00) if @player.bombs > 0
      @font.draw("Time Alive: #{@player.time_alive}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Enemy count: #{@enemies.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("enemy_projectiles: #{@enemy_projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("projectiles count: #{@projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("destructable_proj: #{@enemy_destructable_projectiles.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("pickups count: #{@pickups.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("buildings count: #{@buildings.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Object count: #{@enemies.count + @enemy_projectiles.count + @projectiles.count + @enemy_destructable_projectiles.count + @pickups.count + @buildings.count}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("FPS: #{Gosu.fps}", 10, get_font_ui_y, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
    @gl_background.draw(ZOrder::Background)
    reset_font_ui_y
  end

  def get_font_ui_y
    return_value = @ui_y
    @ui_y += 15 
    return return_value
  end
  def reset_font_ui_y
    @ui_y = 10
  end
end

GameWindow.new.show if __FILE__ == $0
