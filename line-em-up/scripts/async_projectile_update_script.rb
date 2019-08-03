require 'gosu'
require_relative '../models/projectiles/projectile.rb'
require 'json'
require 'oj'

class AsyncProjectileUpdateScript
  # def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
  def self.async_update

    # data = ENV['MARSHALLED_DATA']
    begin
      pid = ENV['PARENT_PID'].to_i
      while Process.getpgid(pid)
        while (line = STDIN.read) && line != ''
          parsed_data = Oj.load(line)
          results = Projectiles::Projectile.async_update(parsed_data['data'], parsed_data['mouse_x'], parsed_data['mouse_y'], parsed_data['player_map_pixel_x'], parsed_data['player_map_pixel_y'])
          STDOUT.write(Oj.dump(results))
        end
      end
    rescue Errno::ESRCH
      exit 0
    end
  end
end

AsyncProjectileUpdateScript.async_update if __FILE__ == $0


# Process.wait(popened_io.pid)