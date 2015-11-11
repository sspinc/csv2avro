require 'spec_helper'

RSpec.describe CSV2Avro do
  describe '#convert' do
    let(:options) { { schema: './spec/support/schema.avsc' } }
    subject(:converter) do
      CSV2Avro.new(options)
    end

    context "Unquoted header" do
      before do
        ARGV.replace ['./spec/support/data.csv']
        converter.convert
      end

      bad_rows_output = "L4: Missing value at name\nL7: Unable to parse\nL9: Missing value at id, Missing value at name\nL10: 'male-shoes' at id doesn't match the type '\"int\"', Missing value at name\n"
      it 'should have bad rows' do
        File.open('./spec/support/data.bad', 'r') do |file|
          expect(file.read).to eq(bad_rows_output)
        end
      end

      it 'should contain the avro data' do
        File.open('./spec/support/data.avro', 'r') do |file|
          expect(AvroReader.new(file).read).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil },
              { 'id'=>4, 'name'=>'male-tops',   'description'=>"Male Tops\nand Male Shirts"},
              { 'id'=>6, 'name'=>'male-shoes', 'description'=>'Male Shoes'}
            ]
          )
        end
      end
    end

    context "Quoted header" do
      before do
        ARGV.replace ['./spec/support/data_quoted.csv']
        converter.convert
      end

      it 'should have a bad row' do
        File.open('./spec/support/data_quoted.bad', 'r') do |file|
          expect(file.read).to eq("L4: Missing value at name\nL7: Unable to parse\n")
        end
      end

      it 'should contain the avro data' do
        File.open('./spec/support/data_quoted.avro', 'r') do |file|
          expect(AvroReader.new(file).read).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil },
              { 'id'=>4, 'name'=>'male-tops',   'description'=>"Male Tops\nand Male Shirts"},
              { 'id'=>6, 'name'=>'male-shoes', 'description'=>'Male Shoes'}
            ]
          )
        end
      end
    end
  end
end
