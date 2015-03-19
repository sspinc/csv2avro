require 'csv2avro/version'
require 'aws-sdk'
require 'avro'
require 'csv'
require 'uri'

class CSV2Avro
  def convert(input_path, output_path, options)
    data_io = Storage.new(input_path).read
    schema_io = Storage.new(options[:schema]).read

  end
end
