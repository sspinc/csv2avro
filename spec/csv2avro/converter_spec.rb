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
        let(:reader) do
          StringIO.new(
            csv_string = CSV.generate do |csv|
              csv << %w[id name description]
              csv << %w[1 dresses Dresses]
              csv << %w[2 female-tops]
            end
            )
        end

        let(:schema) { CSV2Avro::Schema.new(schema_io) }

        let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

        before do
          CSV2Avro::Converter.new(reader, writer, StringIO.new, {}, schema: schema).convert
        end

        it 'should store the data with the given schema' do
          expect(AvroReader.new(writer).read).to eq(
            [
              { 'id'=>1, 'name'=>'dresses',     'description'=>'Dresses' },
              { 'id'=>2, 'name'=>'female-tops', 'description'=>nil }
            ]
          )
        end
      end

      context 'separated with tabs (tsv)' do
        let(:reader) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id name description]
              csv << %w[1 dresses Dresses]
              csv << %w[2 female-tops]
            end
          )
        end

        let(:schema) { CSV2Avro::Schema.new(schema_io) }

        let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

        before do
          CSV2Avro::Converter.new(reader, writer, StringIO.new, { delimiter: "\t" }, schema: schema).convert
        end

        it 'should store the data with the given schema' do
          expect(AvroReader.new(writer).read).to eq(
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
        let(:reader) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id enabled image_links]
              csv << %w[1 true http://www.images.com/dresses.jpeg]
              csv << %w[2 false http://www.images.com/bras1.jpeg,http://www.images.com/bras2.jpeg]
            end
          )
        end

        let(:schema) { CSV2Avro::Schema.new(schema_io) }

        let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

        before do
          CSV2Avro::Converter.new(reader, writer, StringIO.new, { delimiter: "\t" }, schema: schema).convert
        end

        it 'should store the data with the given schema' do
          expect(AvroReader.new(writer).read).to eq(
            [
              { 'id'=>1, 'enabled'=>true,  'image_links'=>['http://www.images.com/dresses.jpeg'] },
              { 'id'=>2, 'enabled'=>false, 'image_links'=>['http://www.images.com/bras1.jpeg', 'http://www.images.com/bras2.jpeg'] }
            ]
          )
        end
      end

      context 'separated with semicolons' do
        let(:reader) do
          StringIO.new(
            csv_string = CSV.generate({col_sep: "\t"}) do |csv|
              csv << %w[id enabled image_links]
              csv << %w[1 true http://www.images.com/dresses.jpeg]
              csv << %w[2 false http://www.images.com/bras1.jpeg;http://www.images.com/bras2.jpeg]
            end
          )
        end

        let(:schema) { CSV2Avro::Schema.new(schema_io) }

        let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

        before do
          CSV2Avro::Converter.new(reader, writer, StringIO.new, { delimiter: "\t", array_delimiter: ';' }, schema: schema).convert
        end

        it 'should store the data with the given schema' do
          expect(AvroReader.new(writer).read).to eq(
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

      let(:reader) do
        StringIO.new(
          csv_string = CSV.generate do |csv|
            csv << %w[id category enabled]
            csv << %w[1 dresses true]
            csv << %w[2  ]
          end
        )
      end

      let(:schema) { CSV2Avro::Schema.new(schema_io) }

      let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

      before do
        CSV2Avro::Converter.new(reader, writer, StringIO.new, { write_defaults: true }, schema: schema).convert
      end

      it 'should store the defaults data' do
        expect(AvroReader.new(writer).read).to eq(
          [
            { 'id'=>1, 'category'=>'dresses', 'size_type'=> 'regular' ,'enabled'=>true },
            { 'id'=>2, 'category'=>'unknown', 'size_type'=> 'regular' ,'enabled'=>false }
          ]
        )
      end
    end

    context 'schema with aliased fields' do
      let(:reader) do
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

      let(:schema) { CSV2Avro::Schema.new(schema_io) }

      let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

      before do
        CSV2Avro::Converter.new(reader, writer, StringIO.new, {}, schema: schema).convert
      end

      it 'should work' do
        expect(AvroReader.new(writer).read).to eq(
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

      let(:reader) do
        StringIO.new(
          csv_string = CSV.generate do |csv|
            csv << %w[id size_type]
            csv << %w[1 regular]
            csv << %W[2 big\sand\stall]
            csv << %w[3 ]
          end
        )
      end

      let(:schema) { CSV2Avro::Schema.new(schema_io) }

      let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

      before do
        CSV2Avro::Converter.new(reader, writer, StringIO.new, { write_defaults: true }, schema: schema).convert
      end

      it 'should store the data with the given schema' do
        expect(AvroReader.new(writer).read).to eq(
          [
            { 'id'=>1, 'size_type'=>'regular' },
            { 'id'=>2, 'size_type'=>'big_and_tall' },
            { 'id'=>3, 'size_type'=>'regular' }
          ]
        )
      end
    end

    context 'data with bad rows' do
      let(:schema_io) do
        StringIO.new(
          {
            name: 'categories',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'name', type: 'string', aliases: ['title'] },
              { name: 'description', type: ['string', 'null'] }
            ]
          }.to_json
        )
      end

      let(:reader) do
        StringIO.new(
          csv_string = CSV.generate({col_sep: "\t"}) do |csv|
            csv << %w[id title description]
            csv << ['1', nil, 'dresses']
            csv << %w[2 female-tops]
            csv << %w[3 female-bottoms]
            csv << ['4', nil, 'female-shoes']
          end
          )
      end

      let(:schema) { CSV2Avro::Schema.new(schema_io) }

      let(:writer) { CSV2Avro::AvroWriter.new(StringIO.new, schema) }

      let(:bad_rows_writer) { StringIO.new }

      before do
        CSV2Avro::Converter.new(reader, writer, bad_rows_writer, { delimiter: "\t" }, schema: schema).convert
      end

      it 'should store the data with the given schema' do
        expect(AvroReader.new(writer).read).to eq(
          [
            { 'id'=>2, 'name'=>'female-tops', 'description'=>nil },
            { 'id'=>3, 'name'=>'female-bottoms', 'description'=>nil }
          ]
        )
      end

      it 'should have the bad data in the original form' do
        expect(bad_rows_writer.string).to eq(
          "id\ttitle\tdescription\n1\t\tdresses\n4\t\tfemale-shoes\n"
        )
      end
    end
  end
end
