require 'avro'

class CSV2Avro
  class AvroWriter
    attr_reader :avro_io
    attr_accessor :bad_rows

    def initialize(schema)
      writer = Avro::IO::DatumWriter.new(schema.avro_schema)
      @avro_io = Avro::DataFile::Writer.new(StringIO.new, writer, schema.avro_schema)

      @bad_rows = StringIO.new
    end

    def writer_schema
      avro_io.datum_writer.writers_schema
    end

    def io
      avro_io.encoder.writer
    end

    def write(hash)
      begin
        avro_io << hash
      rescue Exception
        bad_rows << hash.to_json + "\n"
      end
    end

    def flush
      avro_io.flush
    end

    def close
      avro_io.close
    end
  end
end
