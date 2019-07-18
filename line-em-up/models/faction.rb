class Faction
  attr_reader :id, :color
  attr_reader :factional_relations

  MIN_FACTIONAL_RELATION = -1000
  OPENLY_HOSTILE_AT_OR_LESS = -50
  # 0 is neutral
  DEFAULT_FACTIONAL_RELATION = 0
  OPENLY_DEFEND_AT_OR_GREATER = 50
  MAX_FACTIONAL_RELATION = 1000

  def initialize id, color
    @id = id
    @color = color
    @factional_relations = {}
  end

  def increase_faction_relations faction_name, amount
    # can't increase faction relations to self!
    if faction_name != @id
      @factional_relations[faction_name] = @factional_relations[faction_name] + amount
      @factional_relations[faction_name] = MAX_FACTIONAL_RELATION if @factional_relations[faction_name] > MAX_FACTIONAL_RELATION
    end
  end

  def decrease_faction_relations faction_name, amount
    # can't increase faction relations to self!
    if faction_name != @id
      @factional_relations[faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(faction_name) == false
      @factional_relations[faction_name] = @factional_relations[faction_name] - amount
      @factional_relations[faction_name] = MIN_FACTIONAL_RELATION if @factional_relations[faction_name] < MIN_FACTIONAL_RELATION
    end
  end

  def is_hostile_to? faction_name
    if faction_name == @id
      return false
    else
      @factional_relations[faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(faction_name) == false
      return @factional_relations[faction_name] <= OPENLY_HOSTILE_AT_OR_LESS
    end
  end

  def is_friendly_to? faction_name
    if faction_name == @id
      return true
    else
      @factional_relations[faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(faction_name) == false
      return @factional_relations[faction_name] >= OPENLY_DEFEND_AT_OR_GREATER
    end
  end

  def display_factional_relation faction_name
    if faction_name == @id
      return MAX_FACTIONAL_RELATION / 10
    else
      @factional_relations[faction_name] = DEFAULT_FACTIONAL_RELATION if @factional_relations.key?(faction_name) == false
      return @factional_relations[faction_name] / 10
    end
  end

  # Can move to script
  def self.init_factions
    factions = []
    [
      {name: 'faction_1', color: Gosu::Color.argb(0xff_0066ff)},
      {name: 'faction_2', color: Gosu::Color.argb(0xff_ff0000)},
      {name: 'player',    color: Gosu::Color.argb(0xff_00ff00)}
    ].each do |value|
      factions << Faction.new(value[:name], value[:color])
    end

    return factions
  end
end