module Factionable


  # attr_accessor :faction
  # is overridable on prepending class.
  # DEFAULT_FACTION = 'generic'

  def initialize *args
    # @faction_id = self.class::DEFAULT_FACTION
    super(*args)
  end

  def set_faction faction_id
    @faction = nil
    @factions.each do |faction|
      @faction = faction if faction.id == faction_id
    end
    raise "COULD NOT FIND #{faction_id} for #{self.class}" if @faction.nil?
  end

  def increase_faction_relations other_faction, amount
    @faction.increase_faction_relations(other_faction, amount)
  end

  def decrease_faction_relations other_faction, amount
    @faction.decrease_faction_relations(other_faction, amount)
  end

  def is_hostile_to? faction_name
    @faction.is_hostile_to?(faction_name)
  end

  def is_friendly_to? faction_name
    @faction.is_friendly_to?(faction_name)
  end

  # testing only
  def get_faction_relations
    return @faction.factional_relations
  end


  def get_faction_id
    # puts "SELF>CLAASS: #{self.class}"
    return @faction.id
  end

end