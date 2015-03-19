require 'csv2avro/avro_file'
require 'csv'

class CSV2Avro
  class Converter
    attr_reader :input, :schema, :output_path, :csv_options, :converter_options

    def initialize(input, schema, output_path, options)
      @input = input
      @schema = schema
      @output_path   = output_path

      @csv_options = {
        :headers => true,
        :converters => :all,
        :skip_blanks => true
      }

      @csv_options[:col_sep] = options[:separator] if options[:separator]
      @converter_options = options
    end

    def perform
      avro = CSV2Avro::AvroFile.new(schema, output_path)

       CSV.parse(input, csv_options) do |row|
        row_as_hash = row.to_hash

        avro.write(row_as_hash)
      end

      avro.close
    end
  end
end
