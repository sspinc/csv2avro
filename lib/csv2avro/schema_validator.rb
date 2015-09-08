require 'avro/schema'

class CSV2Avro
  class SchemaValidator

    attr_reader :errors

    def initialize
      @errors = []
    end

    def clear
      @errors.clear
    end

    def validate(expected_schema, datum, name=nil, suppress_error=false)
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
                    (Avro::Schema::INT_MIN_VALUE <= datum) && (datum <= Avro::Schema::INT_MAX_VALUE)
              when :long
                (datum.is_a?(Fixnum) || datum.is_a?(Bignum)) &&
                    (Avro::Schema::LONG_MIN_VALUE <= datum) && (datum <= Avro::Schema::LONG_MAX_VALUE)
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
                  expected_schema.fields.reduce(true){|result, f|
                  validate_result = validate(f.type, datum[f.name], f.name)
                  result && validate_result }
              else
                false
              end

      if !valid && name
        if datum.nil? && expected_type != :null
          @errors << "Missing value at #{name}"
        else
          @errors << "'#{datum}' at #{name} doesn't match the type '#{expected_schema.to_s}'"
        end
      end

      valid
    end
  end
end
