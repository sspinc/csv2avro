require 'csv2avro'
require 'csv2avro/storage'
require 'csv2avro/reader'
require 'csv2avro/converter'
require 'csv2avro/avro_file'

require 'json'

RSpec.configure do |config|
  config.after(:all) do
    Dir["./test/_*"].each do |file|
      File.delete(file)
    end
  end
end
