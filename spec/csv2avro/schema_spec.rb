require 'spec_helper'

RSpec.describe CSV2Avro::Schema do
  describe '#defaults_hash' do
    context 'shema with default values' do
      let(:schema_io) do
        StringIO.new(
          {
            name: 'product',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'category', type: 'string', default: 'unknown' },
              { name: 'enabled', type: ['boolean', 'null'], default: false }
            ]
          }.to_json
        )
      end

      subject(:schema) do
        CSV2Avro::Schema.new(schema_io)
      end

      it 'should return a hash with the field - default value pairs' do
        expect(schema.defaults_hash).to eq({ 'category'=>'unknown', 'enabled'=>false })
      end
    end
  end

  describe '#types_hash' do
    context 'shema with different types' do
      let(:schema_io) do
        StringIO.new(
          {
            name: 'product',
            type: 'record',
            fields: [
              { name: 'id', type: 'int' },
              { name: 'category', type: 'string' },
              { name: 'reviews', type: { type: 'array', items: 'string' }},
              { name: 'enabled', type: ['boolean', 'null'] }
            ]
          }.to_json
        )
      end

      subject(:schema) do
        CSV2Avro::Schema.new(schema_io)
      end

      it 'should return a hash with the field - default value pairs' do
        expect(schema.types_hash).to eq({ 'id'=>'int', 'category'=>'string', 'reviews'=>'array', 'enabled'=>'boolean' })
      end
    end
  end

  describe '#aliases_hash' do
    context 'shema with aliases' do
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

      subject(:schema) do
        CSV2Avro::Schema.new(schema_io)
      end

      it 'should return a hash with the alias - name mapping' do
        expect(schema.aliases_hash).to eq({ 'color_id'=>'look_id', 'photo_group_id'=>'look_id' })
      end
    end
  end
end
