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
      @options = options
      @schema = schema

      # read header row explicitly
      @header = @reader.readline.strip.split(col_sep)
    end

    def convert
      while not csv.eof? do
        begin
          row = csv.shift
        rescue CSV::MalformedCSVError
          error_msg = "row #{row_number}: Unable to parse"
          @error_writer.puts(error_msg)
          @bad_rows_writer.puts(error_msg)
          next
        end
        hash = row.to_hash

        add_defaults_to_hash!(hash) if @options[:write_defaults]
        convert_fields!(hash)

        begin
          @writer.write(hash)
        rescue Avro::IO::AvroTypeError
          error_msg = "row #{row_number}: #{Avro::Schema.errors.join(', ')}"
          @error_writer.puts(error_msg)
          @bad_rows_writer.puts(error_msg)
        end
      end
      @writer.flush
    end

    private

    def array_delimiter
      @options[:array_delimiter] || ','
    end

    def col_sep
      @options[:delimiter] || ','
    end

    def csv_options
      {
        col_sep: col_sep,
        headers: @header,
        header_converters: :aliases,
        skip_blanks: true,
        write_headers: true
      }
    end

    def csv
      # Initialize header converter
      CSV::HeaderConverters[:aliases] = lambda do |header|
        @schema.aliases[header] || header
      end

      @csv ||= CSV.new(@reader, csv_options)
    end

    def row_number
      @reader.lineno + 1
    end

    def add_defaults_to_hash!(hash)
      # Add default values to empty/missing fields
      @schema.defaults.each  do |key, value|
        hash[key] = @schema.defaults[key] if hash[key].nil? or !hash.has_key?(key)
      end
    end

    def convert_fields!(hash)
      @schema.types.each do |key, value|
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
                      else
                        hash[key]
                      end
                    rescue
                      hash[key]
                    end
      end
    end

    def parse_boolean(value)
      case
      when value == true  || value =~ (/^(true|t|yes|y|1)$/i) then true
      when value == false || value =~ (/^(false|f|no|n|0)$/i) then false
      else
        nil
      end
    end

    def parse_array(value)
      value.split(array_delimiter) if value
    end
  end
end
