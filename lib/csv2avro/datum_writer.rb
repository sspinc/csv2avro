require 'avro'
require 'csv2avro/schema_validator'

class CSV2Avro
  class DatumWriter < Avro::IO::DatumWriter

    attr_reader :schema_validator

    def initialize(*args)
      super
      @schema_validator = CSV2Avro::SchemaValidator.new
    end

    def write(datum, encoder)
      schema_validator.clear
      if !schema_validator.validate(writers_schema, datum)
        raise SchemaValidationError.new(schema_validator.errors)
      end
      super
    end
  end

  class SchemaValidationError < StandardError

    attr_reader :errors

    def initialize(schema_errors)
      @errors = schema_errors
    end
  end
end
