require 'csv2avro/schema'
require 'csv2avro/avro_writer'
require 'csv'

class CSV2Avro
  class Converter
    attr_reader :writer, :bad_rows_writer, :schema, :csv, :converter_options, :original_header, :column_separator

    def initialize(reader, writer, bad_rows_writer, options, schema: schema)
      @writer = writer
      @bad_rows_writer = bad_rows_writer
      @schema = schema

      @column_separator = options[:delimiter] || ','

      init_header_converter
      csv_options = {
        headers: true,
        skip_blanks: true,
        return_headers: true,
        col_sep: column_separator,
        header_converters: :aliases
      }

      @csv = CSV.new(reader, csv_options)

      @original_header = deserialize(csv.first.fields)

      @converter_options = options
    end

    def convert
      defaults_hash = schema.defaults_hash if converter_options[:write_defaults]

      fields_to_convert = schema.types_hash.reject{ |key, value| value == :string }

      csv.each do |line|
        row = line.to_hash

        if converter_options[:write_defaults]
          add_defaults_to_hash!(row, defaults_hash)
        end

        convert_fields!(row, fields_to_convert)

        begin
          writer.write(row)
        rescue Exception
          if bad_rows_writer.size == 0
            bad_rows_writer << original_header
          end

          bad_rows_writer << deserialize(line.fields)
        end
      end

      writer.flush
      bad_rows_writer.flush
    end

    private

    def convert_fields!(hash, fields_to_convert)
      fields_to_convert.each do |key, value|
        hash[key] = case value
                    when :int
                      Integer(hash[key]) rescue hash[key]
                    when :float, :double
                      Float(hash[key]) rescue hash[key]
                    when :boolean
                      parse_boolean(hash[key])
                    when :array
                      parse_array(hash[key])
                    when :enum
                      hash[key].downcase.tr(" ", "_")
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

    def add_defaults_to_hash!(hash, defaults_hash)
      # Add default values to nil cells
      hash.each do |key, value|
        hash[key] = defaults_hash[key] if value.nil?
      end

      # Add default values to missing columns
      defaults_hash.each  do |key, value|
        hash[key] = defaults_hash[key]  unless hash.has_key?(key)
      end

      hash
    end

    def init_header_converter
      aliases_hash = schema.aliases_hash

      CSV::HeaderConverters[:aliases] = lambda do |header|
          aliases_hash[header] || header
      end
    end

    def deserialize(line)
      line.join(column_separator) + "\n"
    end
  end
end
