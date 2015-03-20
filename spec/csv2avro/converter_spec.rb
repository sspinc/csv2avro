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

    context 'schema with boolean and array columns' do
      let(:schema) do
        StringIO.new(
          {
            name: 'categories',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'enabled', type: ['boolean', 'null'] },
              { name: 'image_links', type: [{ type: 'array', items: 'string' }, 'null'] }
            ]
          }.to_json
        )
      end

      context 'separated with commas (default)' do
        let(:input) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id enabled image_links]
              csv << %w[1 true http://www.images.com/dresses.jpeg]
              csv << %w[2 false http://www.images.com/bras1.jpeg,http://www.images.com/bras2.jpeg]
            end
          )
        end

        subject(:avro_io) do
          CSV2Avro::Converter.new(input, schema, StringIO.new, {delimiter: "\t"}).perform
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(avro_io).perform).to eq(
            [
              { 'id'=>1, 'enabled'=>true, 'image_links'=>['http://www.images.com/dresses.jpeg'] },
              { 'id'=>2, 'enabled'=>false, 'image_links'=>['http://www.images.com/bras1.jpeg', 'http://www.images.com/bras2.jpeg'] }
            ]
          )
        end
      end

     context 'separated with semicolons' do
        let(:input) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id enabled image_links]
              csv << %w[1 true http://www.images.com/dresses.jpeg]
              csv << %w[2 false http://www.images.com/bras1.jpeg;http://www.images.com/bras2.jpeg]
            end
          )
        end

        subject(:avro_io) do
          CSV2Avro::Converter.new(input, schema, StringIO.new, {delimiter: "\t", array_delimiter: ';'}).perform
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(avro_io).perform).to eq(
            [
              { 'id'=>1, 'enabled'=>true, 'image_links'=>['http://www.images.com/dresses.jpeg'] },
              { 'id'=>2, 'enabled'=>false, 'image_links'=>['http://www.images.com/bras1.jpeg', 'http://www.images.com/bras2.jpeg'] }
            ]
          )
        end
      end
    end
  end
end
