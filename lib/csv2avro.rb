require 'csv2avro/converter'
require 'csv2avro/stream'
require 'csv2avro/version'

class CSV2Avro
  attr_reader :input_path, :schema_path, :bad_rows_path, :std_out_option, :options

  def initialize(input_path, options)
    @input_path = input_path
    @schema_path = options.delete(:schema)
    @bad_rows_path = options.delete(:bad_rows)
    @std_out_option = !input_path || options.delete(:stdout)

    @options = options
  end

  def convert
    Converter.new(reader, writer, bad_rows_writer, options, schema: schema).convert

    clean_up_bad_rows_file unless std_out_option
  end

  private

  def schema
    CSV2Avro::Schema.new(File.open(schema_path, 'r'))
  end

  def reader
    input_path ? File.open(input_path, 'r') : CSV2Avro::Stream.new
  end

  def writer
    writer = if std_out_option
      IO.new(STDOUT.fileno)
    else
      File.open(avro_uri, 'w')
    end

    CSV2Avro::AvroWriter.new(writer, schema)
  end

  def avro_uri
    input_path.split('.')[0..-2].push('avro').join('.')
  end

  def bad_rows_writer
    @writer ||= File.open(bad_rows_uri, 'w')
  end

  def bad_rows_uri
    bad_rows_path || input_path.split('.').insert(-2, 'bad').join('.')
  end

  def clean_up_bad_rows_file
    File.delete(bad_rows_uri) if bad_rows_writer.size == 0
  end
end
