require 'spec_helper'

RSpec.describe CSV2Avro::Converter do
  describe '#perform' do
    context 'schema with string and integer columns' do
      let(:schema) do
        StringIO.new(
          {
            name: 'categories',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'name', type: 'string' },
              { name: 'description', type: ['string', 'null'] }
            ]
          }.to_json
        )
      end

      context 'separated with commas (csv)' do
        let(:input) do
          StringIO.new(
            csv_string = CSV.generate do |csv|
              csv << %w[id name description]
              csv << %w[1 dresses Dresses]
              csv << %w[2 female-tops]
            end
            )
        end

        subject(:avro_io) do
          CSV2Avro::Converter.new(input, schema, StringIO.new, {}).perform
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(avro_io).perform).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
            ]
          )
        end
      end

      context 'separated with tabs (tsv)' do
        let(:input) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id name description]
              csv << %w[1 dresses Dresses]
              csv << %w[2 female-tops]
            end
          )
        end

        subject(:avro_io) do
          CSV2Avro::Converter.new(input, schema, StringIO.new, {delimiter: "\t"}).perform
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(avro_io).perform).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
            ]
          )
        end
      end
    end
  end
end
