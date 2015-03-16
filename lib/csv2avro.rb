require "csv2avro/version"

class CSV2Avro
  def convert(source_path, target_path, options)
    p "Convert file from #{source_path} to #{target_path} with options #{options}"
  end
end
