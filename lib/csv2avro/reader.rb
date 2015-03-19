class CSV2Avro
  class Reader
    def initialize(path, schema=nil)
      @path = path
      @reader = if schema
        schema_file = Avro::Schema.parse(schema)
        Avro::IO::DatumReader.new(nil, schema_file)
      else
        Avro::IO::DatumReader.new
      end
    end

    def perform
      file = File.open(@path, 'r+')

      dr = Avro::DataFile::Reader.new(file, @reader)

      rows = []
      dr.each { |record| rows << record }

      rows
    end
  end
end
