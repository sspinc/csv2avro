require 'csv2avro/schema'
require 'csv2avro/avro_writer'
require 'csv'

class CSV2Avro
  class Converter
    attr_reader :writer, :bad_rows_writer, :schema, :reader, :csv_options, :converter_options, :header_row, :column_separator

    def initialize(reader, writer, bad_rows_writer, options, schema: schema)
      @writer = writer
      @bad_rows_writer = bad_rows_writer
      @schema = schema

      @column_separator = options[:delimiter] || ','

      @reader = reader
      @header_row = reader.readline.strip
      header = header_row.split(column_separator)

      init_header_converter
      @csv_options = {
        headers: header,
        skip_blanks: true,
        col_sep: column_separator,
        header_converters: :aliases
      }

      @converter_options = options
    end

    def convert
      defaults = schema.defaults if converter_options[:write_defaults]

      fields_to_convert = schema.types_hash.reject{ |key, value| value == :string }

      reader.each_line do |line|
        begin
          CSV.parse(line, csv_options) do |row|
            row = row.to_hash

            if converter_options[:write_defaults]
              add_defaults_to_hash!(row, defaults)
            end

            convert_fields!(row, fields_to_convert)

            writer.write(row)
            writer.flush
          end
        rescue Exception
          if bad_rows_writer.size == 0
            bad_rows_writer << header_row + "\n"
          end

          bad_rows_writer << line
          bad_rows_writer.flush
        end
      end
    end

    private

    def convert_fields!(hash, fields_to_convert)
      fields_to_convert.each do |key, value|
        hash[key] = begin
          case value
            when :int
              Integer(hash[key])
            when :float, :double
              BigDecimal(hash[key])
            when :boolean
              parse_boolean(hash[key])
            when :array
              parse_array(hash[key])
            when :enum
              hash[key].downcase.tr(" ", "_")
          end
        rescue
          hash[key]
        end
      end

      hash
    end

    def parse_boolean(value)
      return true  if value == true  || value =~ (/^(true|t|yes|y|1)$/i)
      return false if value == false || value =~ (/^(false|f|no|n|0)$/i)
      nil
    end

    def parse_array(value)
      delimiter = converter_options[:array_delimiter] || ','

      value.split(delimiter) if value
    end

    def add_defaults_to_hash!(hash, defaults)
      # Add default values to nil cells
      hash.each do |key, value|
        hash[key] = defaults[key] if value.nil?
      end

      # Add default values to missing columns
      defaults.each  do |key, value|
        hash[key] = defaults[key]  unless hash.has_key?(key)
      end

      hash
    end

    def init_header_converter
      aliases_hash = schema.aliases_hash

      CSV::HeaderConverters[:aliases] = lambda do |header|
          aliases_hash[header] || header
      end
    end
  end
end
