module Util


  # non-recursive
  def self.hash_string_keys_to_symbols hash_data
    new_hash_clone = {}
    hash_data.each do |key, value|
      # puts key.inspect
      # puts key.class
      # puts "converting key: #{key} to sym"
      # puts key.to_sym.inspect
      new_hash_clone[key.to_sym] = value
    end
    return new_hash_clone
  end

  # recursive
  def self.symbolize_all_keys(hash)
    symbolized_hash = {}
    hash.each do |k, v|
      symbolized_hash[k.to_sym] = v.is_a?(Hash) ? symbolize_all_keys(v) : v
    end
    return symbolized_hash
  end

  def self.stringify_all_keys(hash)
    stringified_hash = {}
    hash.each do |k, v|
      stringified_hash[k.to_s] = v.is_a?(Hash) ? stringify_all_keys(v) : v
    end
    return stringified_hash
  end

end