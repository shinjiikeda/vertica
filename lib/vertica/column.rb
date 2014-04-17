module Vertica
  class Column
    attr_reader :name
    attr_reader :table_oid
    attr_reader :type_modifier
    attr_reader :size
    attr_reader :data_type

    STRING_CONVERTER = lambda { |s| s.force_encoding('utf-8') }

    DATA_TYPE_CONVERSIONS = [
      [:unspecified,  nil],
      [:tuple,        nil],
      [:pos,          nil],
      [:record,       nil],
      [:unknown,      nil],
      [:bool,         lambda { |s| s == 't' }],
      [:integer,      lambda { |s| s.to_i }],
      [:float,        lambda { |s| s.to_f }],
      [:char,         STRING_CONVERTER],
      [:varchar,      STRING_CONVERTER],
      [:date,         lambda { |s| Date.new(*s.split("-").map{|x| x.to_i}) }],
      [:time,         nil],
      [:timestamp,    lambda { |s| DateTime.parse(s, true) }],
      [:timestamp_tz, lambda { |s| DateTime.parse(s, true) }],
      [:interval,     nil],
      [:time_tz,      nil],
      [:numeric,      lambda { |s| BigDecimal.new(s) }],
      [:bytea,        nil],
      [:rle_tuple,    nil]
    ]

    DATA_TYPES = DATA_TYPE_CONVERSIONS.map { |t| t[0] }

    def initialize(col)
      if col[:data_type_oid] == 115
        col[:data_type_oid] = 9
      end
      if col[:data_type_oid] == 116
        col[:data_type_oid] = 3
      end
      @type_modifier    = col[:type_modifier]
      @format           = col[:format_code] == 0 ? :text : :binary
      @table_oid        = col[:table_oid]
      @name             = col[:name].to_sym
      @attribute_number = col[:attribute_number]
      @data_type        = DATA_TYPE_CONVERSIONS[col[:data_type_oid]][0]
      @converter        = DATA_TYPE_CONVERSIONS[col[:data_type_oid]][1]
      @size             = col[:data_type_size]
    end

    def convert(s)
      return unless s
      @converter ? @converter.call(s) : s
    end
  end
end
