require 'avro'

class CSV2Avro
  class AvroFile
    attr_reader :avro_io

    def initialize(schema)
      writer = Avro::IO::DatumWriter.new(schema.avro_schema)
      @avro_io = Avro::DataFile::Writer.new(StringIO.new, writer, schema.avro_schema)
    end

    def writer_schema
      avro_io.datum_writer.writers_schema
    end

    def io
      avro_io.encoder.writer
    end

    def write(hash)
      avro_io << hash
    end

    def flush
      avro_io.flush
    end

    def close
      avro_io.close
    end
  end
end
