require 'csv2avro/converter'
require 'csv2avro/storage'
require 'csv2avro/version'

class CSV2Avro
  def convert(input_path, output_path, options)
    data_io = Storage.new(input_path).read
    schema_io = Storage.new(options[:schema]).read

    Converter.new(data_io, schema_io, output_path, options).perform
  end
end
