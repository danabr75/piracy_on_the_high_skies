module Effect
  class Group

    attr_accessor :effects

    def initialize effects = []
      @effects = effects
    end

    def is_active
      @effects.count > 0
    end

    def update gl_background, ships, buildings, player, center_target
      @effects.reject! do |effect|
        gl_background, ships, buildings, player, center_target = effect.update(gl_background, ships, buildings, player, center_target)
        !effect.is_active
      end

      return [gl_background, ships, buildings, player, center_target, @effects.count]
    end

    def draw
      # Do nothing for now
    end

  end
end