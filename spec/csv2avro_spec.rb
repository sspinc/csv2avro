require 'spec_helper'

RSpec.describe CSV2Avro do
  describe '#convert' do
    let(:options) { { schema: './spec/support/schema.avsc' } }

    before do
      ARGV.replace ['./spec/support/data.csv']
    end
    subject(:converter) { CSV2Avro.new(options) }

    it 'should write errors to STDERR' do
      expect { converter.convert }.to output("line 4: Missing value at name\n").to_stderr
    end

    it 'should have a bad row' do
      File.open('./spec/support/data.bad.csv', 'r') do |file|
        expect(file.read).to eq("id,name,description\n3,,Bras\n")
      end
    end

    it 'should contain the avro data' do
      File.open('./spec/support/data.avro', 'r') do |file|
        expect(AvroReader.new(file).read).to eq(
          [
            { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
            { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
          ]
        )
      end
    end
  end
end
