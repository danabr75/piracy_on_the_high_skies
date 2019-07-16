require_relative 'animation.rb'

module Graphics
  class Explosion < Graphics::Animation
    def self.get_frames
      return Gosu::Image.load_tiles("#{MEDIA_DIRECTORY}/explosion.png", 128, 128)
    end
  end
end