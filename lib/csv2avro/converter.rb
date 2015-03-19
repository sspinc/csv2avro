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

       CSV.parse(input, csv_options) do |row|
        row_as_hash = row.to_hash

        avro.write(row_as_hash)
      end

      avro.flush
      avro.io
    end
  end
end
