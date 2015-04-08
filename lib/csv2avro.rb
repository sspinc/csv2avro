require 'csv2avro/converter'
require 'csv2avro/storage'
require 'csv2avro/version'

class CSV2Avro
  def convert(input_uri, output_uri, options)
    schema_uri = options.delete(:schema)

    reader = Storage.new(input_uri).open
    schema = CSV2Avro::Schema.new(Storage.new(schema_uri).open) if schema_uri

    writer = CSV2Avro::AvroWriter.new(StringIO.new, schema)
    bad_rows_writer = StringIO.new

    Converter.new(reader, writer, bad_rows_writer, options, schema: schema).convert

    Storage.new(output_uri).write(writer.avro_writer.writer.string)
    Storage.new(output_uri + '.bad').write(bad_rows_writer.string) if bad_rows_writer.string != ''
  end
end
