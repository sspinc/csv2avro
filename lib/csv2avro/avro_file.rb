class CSV2Avro
  class AvroFile
    def initialize(schema_string, output_path)
      output_file = File.open(output_path, 'wb')

      schema = Avro::Schema.parse(schema_string)
      writer = Avro::IO::DatumWriter.new(schema)

      @avro = Avro::DataFile::Writer.new(output_file, writer, schema)
    end

    def writer_schema
      @avro.datum_writer.writers_schema
    end

    def write(hash)
      @avro << hash
    end

    def close
      @avro.close
    end
  end
end
