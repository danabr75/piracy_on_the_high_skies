# require_relative '../lib/global_constants'
require_relative '../lib/global_variables.rb'

class Faction
  # include GlobalVariables
  include GlobalConstants

  attr_reader :id, :displayed_name, :color
  attr_reader :factional_relations
  attr_reader :emblem, :emblem_scaler, :emblem_width_half, :emblem_height_half, :emblem_info

  MIN_FACTIONAL_RELATION = -100
  OPENLY_HOSTILE_AT_OR_LESS = -50
  # 0 is neutral
  DEFAULT_FACTIONAL_RELATION = 0
  OPENLY_DEFEND_AT_OR_GREATER = 50
  MAX_FACTIONAL_RELATION = 100

  EMBLEM_SCALER = 16.0

  def initialize id, displayed_name, color, height_scale
    @id = id
    @displayed_name = displayed_name
    @color = color
    @factional_relations = {}
    @emblem = Gosu::Image.new("#{MEDIA_DIRECTORY}/factions/#{@id}.png")
    @emblem_info = @emblem.gl_tex_info
    @emblem_width  = (@emblem.width  / 2.0) / height_scale
    @emblem_width_half  = @emblem_width / 2.0
    @emblem_height = (@emblem.height / 2.0) / height_scale
    @emblem_height_half  = @emblem_height / 2.0
    @emblem_scaler = height_scale / EMBLEM_SCALER
  end

  # only to be used by other factions!
  def set_factional_relations other_faction_name, value
    @factional_relations[other_faction_name] = value
  end

  def increase_faction_relations other_faction_name, amount
    # can't increase faction relations to self!
    if other_faction_name != @id
      @factional_relations[other_faction_name] = @factional_relations[other_faction_name] + amount
      @factional_relations[other_faction_name] = MAX_FACTIONAL_RELATION if @factional_relations[other_faction_name] > MAX_FACTIONAL_RELATION
    end
  end

  def decrease_faction_relations other_faction_name, other_faction, amount
    # can't increase faction relations to self!
    if other_faction_name != @id
      @factional_relations[other_faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(other_faction_name) == false
      @factional_relations[other_faction_name] = @factional_relations[other_faction_name] - amount
      @factional_relations[other_faction_name] = MIN_FACTIONAL_RELATION if @factional_relations[other_faction_name] < MIN_FACTIONAL_RELATION

      # Set other faction hostile to self if relations are now hostile.
      if is_hostile_to?(other_faction_name) && !other_faction.is_hostile_to?(@id)
        other_faction.set_factional_relations(@id, OPENLY_HOSTILE_AT_OR_LESS)
      end
    end
  end

  def is_hostile_to? other_faction_name
    if other_faction_name == @id
      return false
    else
      @factional_relations[other_faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(other_faction_name) == false
      return @factional_relations[other_faction_name] <= OPENLY_HOSTILE_AT_OR_LESS
    end
  end

  def is_friendly_to? other_faction_name
    if other_faction_name == @id
      return true
    else
      @factional_relations[other_faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(other_faction_name) == false
      return @factional_relations[other_faction_name] >= OPENLY_DEFEND_AT_OR_GREATER
    end
  end

  def display_factional_relation other_faction_name
    if other_faction_name == @id
      return MAX_FACTIONAL_RELATION / 10
    else
      @factional_relations[other_faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(other_faction_name) == false
      return @factional_relations[other_faction_name] / 10
    end
  end

  def get_relations
    @factional_relations
  end
  # Can move to script
  def self.init_factions height_scale
    factions = []
    [
      {displayed_name: "USSR",    name: 'faction_1', color: Gosu::Color.argb(0xff_FF0000)},
      {displayed_name: "Bandits", name: 'faction_2', color: Gosu::Color.argb(0xff_ffffff)},
      {displayed_name: "Fortune's Horizon", name: 'player',    color: Gosu::Color.argb(0xff_00ff00)}
    ].each do |value|
      factions << Faction.new(value[:name], value[:displayed_name], value[:color], height_scale)
    end

    return factions
  end
end