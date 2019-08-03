# gem install bson
# gem install bson_ext
# gem install yajl-ruby
# gem install json
# gem install msgpack
# gem install oj

require 'oj'
require 'rubygems'
require 'benchmark'
require 'yaml'
# require 'bson'
require 'json'
require 'yajl'
require 'msgpack'

def encode(msg, format)
  case format
  when :yaml
    str = msg.to_yaml
  when :binary
    str = Marshal.dump(msg)
  when :json
    str = JSON.generate(msg)
  when :yajl
    str = Yajl::Encoder.encode(msg)
  # when :bson
  #   str = msg.to_bson
  when :msgpack
    str = MessagePack.pack(msg)
  when :oj
    str = Oj.dump(str)
  end
  str
end

def decode(str, format)  
  msg = nil
  case format
  when :yaml
    msg = YAML.load(str)
  when :binary
    msg = Marshal.load(str)
  when :json
    msg = JSON.parse(str)
  when :yajl
    msg = Yajl::Parser.parse(str)
  # when :bson
  #   msg = String.from_bson(str)
  when :msgpack
    msg = MessagePack.unpack(str)
  when :oj
    msg = Oj.load(str)
  end
  msg
end

SAMPLES = 5000
obj = {
  :name => "Fredrick Smith",
  :quantity => 1_000_000,
  :addresses => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :name1 => "Fredrick Smith",
  :name2 => "Fredrick Smith",
  :name3 => "Fredrick Smith",
  :name4 => "Fredrick Smith",
  :name5 => "Fredrick Smith",
  :name6 => "Fredrick Smith",
  :name7 => "Fredrick Smith",
  :name8 => "Fredrick Smith",
  :name9 => "Fredrick Smith",
  :name0 => "Fredrick Smith",
  :name11 => "Fredrick Smith",
  :name12 => "Fredrick Smith",
  :name13 => "Fredrick Smith",
  :name14 => "Fredrick Smith",
  :addresses1 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses2 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses3 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses4 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses5 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses6 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses7 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses8 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses15 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses14 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses13 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses12 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses11 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
  :quantity => 1_000_000,
  :addresses11 => {
    :address1 => "12 Heather Street, Parnell, Auckland, New Zealand",
    :address2 => "1 Queen Street, CBD, Auckland, New Zealand"
  },
}

Benchmark.bmbm do |r|
  r.report("OJ") do
    SAMPLES.times do
      decode(encode(obj, :oj), :oj)
    end
  end

  r.report("Marshal") do
    SAMPLES.times do
      decode(encode(obj, :binary), :binary)
    end
  end

  r.report("JSON (built-in ruby 2.6.3)") do
    SAMPLES.times do
      decode(encode(obj, :json), :json)
    end
  end

  r.report("JSON (using Yajl)") do
    SAMPLES.times do
      decode(encode(obj, :yajl), :yajl)
    end
  end

  # r.report("BSON") do
  #   SAMPLES.times do
  #     decode(encode(obj, :bson), :bson)
  #   end
  # end

  r.report("YAML") do
    SAMPLES.times do
      decode(encode(obj, :yaml), :yaml)
    end
  end

  r.report("MessagePack") do
    SAMPLES.times do
      msg = decode(encode(obj, :msgpack), :msgpack)
    end
  end

end