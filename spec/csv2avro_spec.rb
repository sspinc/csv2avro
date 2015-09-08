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
      end

      bad_rows_output = "row 4: Missing value at name\nrow 7: Unable to parse\nrow 9: Missing value at id, Missing value at name\nrow 10: 'male-shoes' at id doesn't match the type '\"int\"', Missing value at name\n"
      it 'should write errors to STDERR' do
        expect { converter.convert }.to output(bad_rows_output).to_stderr
      end

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
      end

      it 'should write errors to STDERR' do
        expect { converter.convert }.to output("row 4: Missing value at name\nrow 7: Unable to parse\n").to_stderr
      end

      it 'should have a bad row' do
        File.open('./spec/support/data_quoted.bad', 'r') do |file|
          expect(file.read).to eq("row 4: Missing value at name\nrow 7: Unable to parse\n")
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
