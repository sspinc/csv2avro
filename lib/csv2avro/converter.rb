require 'csv2avro/schema'
require 'csv2avro/avro_writer'
require 'csv'

class CSV2Avro
  class Converter
    def initialize(reader, writer, bad_rows_writer, error_writer, options, schema: schema)
      @reader = reader
      @writer = writer
      @bad_rows_writer = bad_rows_writer
      @error_writer = error_writer
      @schema = schema

      col_sep = options[:delimiter] || ','

      header = @reader.readline.strip.split(col_sep)

      init_header_converter
      @csv_options = {
        col_sep: col_sep,
        headers: header,
        header_converters: :aliases,
        skip_blanks: true,
        write_headers: true
      }

      @options = options
    end

    def convert
      defaults = @schema.defaults if @options[:write_defaults]

      fields_to_convert = @schema.types.reject { |key, value| value == :string }

      csv.each do |row|
        hash = row.to_hash

        if @options[:write_defaults]
          add_defaults_to_hash!(hash, defaults)
        end

        convert_fields!(hash, fields_to_convert)

        begin
          @writer.write(hash)
        rescue Avro::IO::AvroTypeError
          bad_rows_csv << row

          until Avro::Schema.errors.empty? do
            @error_writer << "line #{@reader.lineno}: #{Avro::Schema.errors.shift}\n"
          end
        end
      end
    end

    private


    def csv
      @csv ||= CSV.new(@reader, @csv_options)
    end

    def bad_rows_csv
      @bad_rows_csv ||= CSV.new(@bad_rows_writer, @csv_options)
    end

    def convert_fields!(hash, fields)
      fields.each do |key, value|
        hash[key] = begin
          case value
            when :int
              Integer(hash[key])
            when :float, :double
              Float(hash[key])
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
      delimiter = @options[:array_delimiter] || ','

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
      aliases = @schema.aliases

      CSV::HeaderConverters[:aliases] = lambda do |header|
          aliases[header] || header
      end
    end
  end
end
