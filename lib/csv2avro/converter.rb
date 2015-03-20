require 'csv2avro/schema_utils'
require 'csv2avro/avro_file'
require 'csv'

class CSV2Avro
  class Converter
    attr_reader :input, :schema, :output, :csv_options, :converter_options

    def initialize(input, schema, output, options)
      @input = input
      @schema = schema
      @output   = output

      @csv_options = {
        :headers => true,
        :converters => :all,
        :skip_blanks => true
      }

      @csv_options[:col_sep] = options[:delimiter] if options[:delimiter]
      @converter_options = options
    end

    def perform
      avro = CSV2Avro::AvroFile.new(schema, output)
      init_header_converter

      schama_utils = CSV2Avro::SchemaUtils.new(avro.writer_schema)

      boolean_columns = schama_utils.column_names_with_type(:boolean)
      array_columns   = schama_utils.column_names_with_type(:array)

      defaults_hash = schama_utils.defaults_hash if converter_options[:write_defaults]

      CSV.parse(input, csv_options) do |row|
        row_as_hash = row.to_hash

        boolean_columns.each do |column|
          value = row_as_hash[column]
          row_as_hash[column] = parse_boolean(value) if value
        end

        array_columns.each do |column|
          value = row_as_hash[column]
          row_as_hash[column] = parse_array(value) if value
        end

        if converter_options[:write_defaults]
          row_as_hash = add_defaults_to_hash(row_as_hash, defaults_hash)
        end

        avro.write(row_as_hash)
      end

      avro.flush
      avro.io
    end

    private

    def parse_boolean(value)
      return true  if value == true  || value =~ (/^(true|t|yes|y|1)$/i)
      return false if value == false || value =~ (/^(false|f|no|n|0)$/i)
      nil
    end

    def parse_array(value)
      delimiter = converter_options[:array_delimiter] || ','

      value.split(delimiter) if value
    end

    def add_defaults_to_hash(hash, defaults_hash)
      Hash[
        hash.map do |key, value|
          if value.nil?
            [key, defaults_hash[key]]
          else
            [key, value]
          end
        end
      ]
    end

    def init_header_converter
      aliases_hash = CSV2Avro::SchemaUtils.aliases_hash(schema.string)

      CSV::HeaderConverters[:aliases] = lambda do |header|
          aliases_hash[header] || header
      end

      csv_options[:header_converters] = :aliases
    end
  end
end
