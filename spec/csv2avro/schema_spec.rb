require 'spec_helper'

RSpec.describe CSV2Avro::Schema do
  describe '#defaults' do
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
        expect(schema.defaults).to eq({ 'category'=>'unknown', 'enabled'=>false })
      end
    end
  end

  describe '#types' do
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
              { name: 'enabled', type: ['boolean', 'null'] },
              { name: 'availability', type: {
                  type:'enum', name:'availability_values', symbols:['in_stock', 'out_of_stock', 'preorder']
                }, default: 'in_stock'
              }
            ]
          }.to_json
        )
      end

      subject(:schema) do
        CSV2Avro::Schema.new(schema_io)
      end

      it 'should return a hash with the field - default value pairs' do
        expect(schema.types).to eq({ 'id'=>:int, 'category'=>:string, 'reviews'=>:array, 'enabled'=>:boolean, 'availability'=>:enum })
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
