require 'spec_helper'

RSpec.describe CSV2Avro::Converter do
  describe '#read' do
    context 'schema with string and integer columns' do
      let(:schema_io) do
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

        subject(:converted_data) do
          schema = CSV2Avro::Schema.new(schema_io)
          converter = CSV2Avro::Converter.new(input, {}, schema: schema)
          converter.perform
          converter.read
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(converted_data).read).to eq(
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

        subject(:converted_data) do
          schema = CSV2Avro::Schema.new(schema_io)
          converter = CSV2Avro::Converter.new(input, { delimiter: "\t" }, schema: schema)
          converter.perform
          converter.read
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(converted_data).read).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
            ]
          )
        end
      end
    end

    context 'schema with boolean and array columns' do
      let(:schema_io) do
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

        subject(:converted_data) do
          schema = CSV2Avro::Schema.new(schema_io)
          converter = CSV2Avro::Converter.new(input, {delimiter: "\t"}, schema: schema)
          converter.perform
          converter.read
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(converted_data).read).to eq(
            [
              { 'id'=>1, 'enabled'=>true,  'image_links'=>['http://www.images.com/dresses.jpeg'] },
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

        subject(:converted_data) do
          schema = CSV2Avro::Schema.new(schema_io)
          converter = CSV2Avro::Converter.new(input, { delimiter: "\t", array_delimiter: ';' }, schema: schema)
          converter.perform
          converter.read
        end

        it 'should store the data with the given schema' do
          expect(CSV2Avro::Reader.new(converted_data).read).to eq(
            [
              { 'id'=>1, 'enabled'=>true,  'image_links'=>['http://www.images.com/dresses.jpeg'] },
              { 'id'=>2, 'enabled'=>false, 'image_links'=>['http://www.images.com/bras1.jpeg', 'http://www.images.com/bras2.jpeg'] }
            ]
          )
        end
      end
    end

    context 'shema with default vaules' do
      let(:schema_io) do
        StringIO.new(
          {
            name: 'product',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'category',  type: 'string', default: 'unknown' },
              { name: 'size_type', type: 'string', default: 'regular' },
              { name: 'enabled',   type: ['boolean', 'null'], default: false }
            ]
          }.to_json
        )
      end

      let(:input) do
        StringIO.new(
          csv_string = CSV.generate do |csv|
            csv << %w[id category enabled]
            csv << %w[1 dresses true]
            csv << %w[2  ]
          end
        )
      end

      subject(:converted_data) do
        schema = CSV2Avro::Schema.new(schema_io)
        converter = CSV2Avro::Converter.new(input, { write_defaults: true }, schema: schema)
        converter.perform
        converter.read
      end

      it 'should store the defaults data' do
        expect(CSV2Avro::Reader.new(converted_data).read).to eq(
          [
            { 'id'=>1, 'category'=>'dresses', 'size_type'=> 'regular' ,'enabled'=>true },
            { 'id'=>2, 'category'=>'unknown', 'size_type'=> 'regular' ,'enabled'=>false }
          ]
        )
      end
    end

    context 'schema with aliased fields' do
      let(:input) do
        StringIO.new(
          csv_string = CSV.generate do |csv|
            csv << %w[id color_id]
            csv << %w[1 1_red]
            csv << %w[2 2_blue]
          end
        )
      end

      let(:schema_io) do
        StringIO.new(
          {
            name: 'product',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'look_id', type: 'string', aliases: ['color_id', 'photo_group_id'] }
            ]
          }.to_json
        )
      end

      subject(:converted_data) do
        schema = CSV2Avro::Schema.new(schema_io)
        converter = CSV2Avro::Converter.new(input, {}, schema: schema)
        converter.perform
        converter.read
      end

      it 'should work' do
        expect(CSV2Avro::Reader.new(converted_data).read).to eq(
          [
            {'id'=>1, 'look_id'=>'1_red'},
            {'id'=>2, 'look_id'=>'2_blue'}
          ]
        )
      end
    end

    context 'schema with enum column' do
      let(:schema_io) do
        StringIO.new(
          {
            name: 'product',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'size_type', type:
                [
                  {
                    type:'enum', name:'size_type_values', symbols:['regular', 'petite', 'plus', 'tall', 'big_and_tall', 'maternity']
                  }, 'null'
                ], default: 'regular'
              }
            ]
          }.to_json
        )
      end

      let(:input) do
        StringIO.new(
          csv_string = CSV.generate do |csv|
            csv << %w[id size_type]
            csv << %w[1 regular]
            csv << %W[2 big\sand\stall]
            csv << %w[3 ]
          end
        )
      end

      subject(:converted_data) do
        schema = CSV2Avro::Schema.new(schema_io)
        converter = CSV2Avro::Converter.new(input, { write_defaults: true }, schema: schema)
        converter.perform
        converter.read
      end

      it 'should store the data with the given schema' do
        expect(CSV2Avro::Reader.new(converted_data).read).to eq(
          [
            { 'id'=>1, 'size_type'=>'regular' },
            { 'id'=>2, 'size_type'=>'big_and_tall' },
            { 'id'=>3, 'size_type'=>'regular' }
          ]
        )
      end
    end
  end
end
