module Factionable


  # attr_accessor :faction
  # is overridable on prepending class.
  # DEFAULT_FACTION = 'generic'

  def initialize *args
    # @faction_id = self.class::DEFAULT_FACTION
    result = super(*args)
    @faction_font_height = (12 * @height_scale).to_i
    @faction_font  = Gosu::Font.new(@faction_font_height, {bold: true})
    # raise "FACTION WAS NOT SET - Please call `set_faction` on initialized object - #{self.class}" if @faction.nil?
    return result
  end

  def draw *args
  # def draw viewable_pixel_offset_x, viewable_pixel_offset_y#, options = {:show_factions = false}
    result = super(*args)
    # result = super(viewable_pixel_offset_x, viewable_pixel_offset_y)
    # @faction.emblem.draw(@x - @faction.emblem_width_half, @y - @faction.emblem_height_half, ZOrder::FactionEmblem, @faction.emblem_scaler, @faction.emblem_scaler)
    return result
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
    if @faction
      return @faction.id
    else
      return super
    end
  end

  def get_faction_color
    # puts "SELF>CLAASS: #{self.class}"
    return @faction.color
  end

end