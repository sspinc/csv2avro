require 'csv2avro/converter'
require 'csv2avro/stream'
require 'csv2avro/version'

class CSV2Avro
  attr_reader :input_uri, :schema_uri, :bad_rows_uri, :options

  def initialize(input_uri, options)
    @input_uri = input_uri
    @schema_uri = options.delete(:schema)
    @bad_rows_uri = options.delete(:bad_rows)

    @options = options
  end

  def convert
    Converter.new(reader, writer, bad_rows_writer, options, schema: schema).convert
  end

  private

  def schema
    CSV2Avro::Schema.new(File.open(schema_uri, 'r'))
  end

  def reader
    input_uri ? File.open(input_uri, 'r') : CSV2Avro::Stream.new
  end

  def writer
    writer = if input_uri
      file_name = input_uri.split('.')[0..-2].push('avro').join('.')
      File.open(file_name, 'w')
    else
      IO.new(STDOUT.fileno)
    end

    CSV2Avro::AvroWriter.new(writer, schema)
  end

  def bad_rows_writer
    uri = bad_rows_uri || input_uri.split('.').insert(-2, 'bad').join('.')
    File.open(uri, 'w')
  end
end
