require 'spec_helper'

RSpec.describe CSV2Avro::SchemaUtils do
  describe '#column_names_with_type' do
    context 'shema with an array field' do
      let(:schema_string) do
        {
          name: 'product',
          type: 'record',
          fields: [
            { name: 'id', type: 'int' },
            { name: 'image_links', type: [{ type: 'array', items: 'string' }, 'null'] }
          ]
        }.to_json
      end

      subject(:schema_utils) do |variable|
        schema = Avro::Schema.parse(schema_string)
        CSV2Avro::SchemaUtils.new(schema)
      end

      it 'should return one array field' do
        expect(schema_utils.column_names_with_type(:array)).to eq(['image_links'])
      end
    end

    context 'shema with multiple array fields' do
      let(:schema_string) do
        {
          name: 'product',
          type: 'record',
          fields: [
            { name: 'id', type: 'int' },
            { name: 'reviews', type: { type: 'array', items: 'string' }},
            { name: 'image_links', type: [{ type: 'array', items: 'string' }, 'null'] }
          ]
        }.to_json
      end

      subject(:schema_utils) do |variable|
        schema = Avro::Schema.parse(schema_string)
        CSV2Avro::SchemaUtils.new(schema)
      end

      it 'should return multiple array fields' do
        expect(schema_utils.column_names_with_type(:array)).to eq(['reviews', 'image_links'])
      end
    end
  end

  describe '#defaults_hash' do
    context 'shema with default values' do
      let(:schema_string) do
        {
          name: 'product',
          type: 'record',
          fields: [
            { name: 'id', type: 'int' },
            { name: 'category', type: 'string', default: 'unknown' },
            { name: 'enabled', type: ['boolean', 'null'], default: false }
          ]
        }.to_json
      end

      subject(:schema_utils) do |variable|
        schema = Avro::Schema.parse(schema_string)
        CSV2Avro::SchemaUtils.new(schema)
      end

      it 'should return a hash with the field - default value pairs' do
        expect(schema_utils.defaults_hash).to eq({ 'id'=>nil, 'category'=>'unknown', 'enabled'=>false })
      end
    end
  end


  describe '.aliases_hash' do
    context 'shema with aliases' do
      let(:schema_string) do
        {
          name: 'product',
          type: 'record',
          fields: [
            { name: 'id', type: 'int' },
            { name: 'look_id', type: 'string', aliases: ['color_id', 'photo_group_id'] }
          ]
        }.to_json
      end

      it 'should return a hash with the alias - name mapping' do
        expect(CSV2Avro::SchemaUtils.aliases_hash(schema_string)).to eq({ 'color_id'=>'look_id', 'photo_group_id'=>'look_id' })
      end
    end
  end
end
