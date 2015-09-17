require 'csv2avro/converter'
require 'csv2avro/version'
require 'csv2avro/log'

class CSV2Avro
  attr_reader :input_path, :schema_path, :bad_rows_path, :stdout_option, :options

  def initialize(options)
    @input_path = ARGV.first
    @schema_path = options.delete(:schema)
    @bad_rows_path = options.delete(:bad_rows)
    @stdout_option = !input_path || options.delete(:stdout)

    @options = options
    Log.puts(message: "Started processing #{File.basename(input_path)}")
  end

  def convert
    Converter.new(reader, writer, bad_rows_writer, error_writer, options, schema: schema).convert
  ensure
    writer.close if writer
    bad_rows_writer.close
  end

  private

  def schema
    @schema ||= File.open(schema_path, 'r') do |schema|
      CSV2Avro::Schema.new(schema)
    end
  end

  def reader
    ARGF.lineno = -1
    ARGF
  end

  def writer
    @__writer ||= begin
      writer = if stdout_option
        IO.new(STDOUT.fileno)
      else
        File.open(avro_uri, 'w')
      end

      CSV2Avro::AvroWriter.new(writer, schema)
    end
  end

  def avro_uri
    dir = File.dirname(input_path)
    ext = File.extname(input_path)
    name = File.basename(input_path, ext)

    "#{dir}/#{name}.avro"
  end

  def error_writer
    Log
  end

  def bad_rows_writer
    @__bad_rows_writer ||= File.open(bad_rows_uri, 'w')
  end

  def bad_rows_uri
    return bad_rows_path if bad_rows_path

    dir = File.dirname(input_path)
    ext = File.extname(input_path)
    name = File.basename(input_path, ext)

    "#{dir}/#{name}.bad"
  end
end
