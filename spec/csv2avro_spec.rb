require 'spec_helper'

RSpec.describe CSV2Avro do
  describe '#convert' do
    let(:input_uri) { './spec/support/data.tsv' }
    let(:options) do
      {
        schema: './spec/support/schema.avsc'
      }
    end

    before do
      CSV2Avro.new(input_uri, options).convert
    end

    subject(:bad_rows_file) do
      File.open(URI('./spec/support/data.bad.tsv').path, 'r')
    end

    subject(:avro_file) do
      File.open(URI('./spec/support/data.avro').path, 'r')
    end

    it 'should not have any bad rows' do
      expect(bad_rows_file.read).to eq('id,name,description\n3,,Bras\n')
    end

    it 'should contain the avro data' do
      expect(AvroReader.new(avro_file).read).to eq(
        [
          { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
          { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
        ]
      )
    end
  end
end
