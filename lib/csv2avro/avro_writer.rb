require 'avro'
require 'forwardable'

class CSV2Avro
  class AvroWriter
    extend Forwardable

    attr_reader :avro_writer

    def_delegators :'avro_writer.writer', :seek, :read, :eof?
    def_delegators :avro_writer, :flush, :close

    def initialize(writer, schema)
      datum_writer = Avro::IO::DatumWriter.new(schema.avro_schema)
      @avro_writer = Avro::DataFile::Writer.new(writer, datum_writer, schema.avro_schema)
    end

    def writer_schema
      avro_writer.datum_writer.writers_schema
    end

    def write(hash)
      avro_writer << hash
    end
  end
end
