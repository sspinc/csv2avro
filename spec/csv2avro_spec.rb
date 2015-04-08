require 'spec_helper'

RSpec.describe CSV2Avro do
  describe '#convert' do
    let(:input_uri) { "file://#{Dir.pwd}/test/data.tsv" }
    let(:output_uri) { "file://#{Dir.pwd}/test/result.avro" }
    let(:options) do
      {
        schema: "file://#{Dir.pwd}/test/schema.avsc",
        delimiter: "\t"
      }
    end

    subject(:converted_file) do
      CSV2Avro.new.convert(input_uri, output_uri, options)

      File.open(URI(output_uri).path, 'r')
    end

    it 'should be fine' do
      expect(CSV2Avro::Reader.new(converted_file).read).to eq(
        [
          { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
          { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
        ]
      )
    end
  end
end
