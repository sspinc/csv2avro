class AvroReader
  attr_reader :io

  def initialize(io, schema=nil)
    @io = io
    @reader = if schema
      schema_file = Avro::Schema.parse(schema)
      Avro::IO::DatumReader.new(nil, schema_file)
    else
      Avro::IO::DatumReader.new
    end
  end

  def read
    dr = Avro::DataFile::Reader.new(io, @reader)

    rows = []
    dr.each { |record| rows << record }

    rows
  end
end
