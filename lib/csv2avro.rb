require 'csv2avro/converter'
require 'csv2avro/storage'
require 'csv2avro/version'

class CSV2Avro
  def convert(input_path, output_path, options)
    data_io = Storage.new(input_path).read
    schema_io = Storage.new(options[:schema]).read

    schema = CSV2Avro::Schema.new(schema_io)
    avro_io = Converter.new(data_io, schema, StringIO.new, options).perform

    Storage.new(output_path).write(avro_io)
  end
end
