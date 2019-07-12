require 'gosu'
require_relative '../models/projectile.rb'
require 'json'

class AsyncProjectileUpdateScript
  # def self.async_update data, mouse_x, mouse_y, player_map_pixel_x, player_map_pixel_y, results = {}
  def self.async_update
    data = ENV['MARSHALLED_DATA']
    args = ENV['ARGS']
    parsed_data = JSON.parse(data)
    parsed_args = JSON.parse(args)
    results = Projectile.async_update(parsed_data, parsed_args[0], parsed_args[1], parsed_args[2], parsed_args[3])
    test = results.merge({writein: true}).to_json
    for_fun = JSON.parse(test)
    STDOUT.write(test)
    exit 0
  end

end

AsyncProjectileUpdateScript.async_update if __FILE__ == $0
