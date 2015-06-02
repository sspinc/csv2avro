module Avro
  class Schema
    @errors = []

    class << self
      attr_accessor :errors
    end

    def self.validate(expected_schema, datum, name=nil, suppress_error=false)
      expected_type = expected_schema.type_sym

      valid = case expected_type
              when :null
                datum.nil?
              when :boolean
                datum == true || datum == false
              when :string, :bytes
                datum.is_a? String
              when :int
                (datum.is_a?(Fixnum) || datum.is_a?(Bignum)) &&
                    (INT_MIN_VALUE <= datum) && (datum <= INT_MAX_VALUE)
              when :long
                (datum.is_a?(Fixnum) || datum.is_a?(Bignum)) &&
                    (LONG_MIN_VALUE <= datum) && (datum <= LONG_MAX_VALUE)
              when :float, :double
                datum.is_a?(Float) || datum.is_a?(Fixnum) || datum.is_a?(Bignum)
              when :fixed
                datum.is_a?(String) && datum.size == expected_schema.size
              when :enum
                expected_schema.symbols.include? datum
              when :array
                datum.is_a?(Array) &&
                  datum.all?{|d| validate(expected_schema.items, d) }
              when :map
                datum.keys.all?{|k| k.is_a? String } &&
                  datum.values.all?{|v| validate(expected_schema.values, v) }
              when :union
                expected_schema.schemas.any?{|s| validate(s, datum, nil, true) }
              when :record, :error, :request
                datum.is_a?(Hash) &&
                  expected_schema.fields.all?{|f| validate(f.type, datum[f.name], f.name) }
              else
                false # raise "you suck #{expected_schema.inspect} is not allowed."
              end

      if !suppress_error && !valid && name
        if datum.nil? && expected_type != :null
          @errors << "Missing value at #{name}"
        else
          @errors << "'#{datum}' at #{name} does'n match the type '#{expected_schema.to_s}'"
        end
      end

      valid
    end
  end
end
