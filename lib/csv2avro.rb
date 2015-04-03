require 'csv2avro/converter'
require 'csv2avro/storage'

class CSV2Avro
  def convert(input_uri, output_uri, options)
    schema_uri = options.delete(:schema)

    input = Storage.new(input_uri)
    schema = CSV2Avro::Schema.new(Storage.new(schema_uri)) if schema_uri

    converter = Converter.new(input, options, schema: schema)

    Storage.new(output_uri).write(converter.read)
  end
end
