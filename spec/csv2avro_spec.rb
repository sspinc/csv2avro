require 'spec_helper'

RSpec.describe CSV2Avro do
  describe '#convert' do
    let(:input_uri) { "./test/data.tsv" }
    let(:options) do
      {
        schema: "./test/schema.avsc",
        delimiter: "\t"
      }
    end

    subject(:converted_file) do
      CSV2Avro.new(input_uri, options).convert

      File.open(URI("./test/data.tsv.avro").path, 'r')
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
