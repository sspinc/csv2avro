require 'spec_helper'

RSpec.describe CSV2Avro::Converter do
  describe '#perform' do
    context 'fields with different types' do
      let(:input_string) do
        "id,name,description
         1,dresses,Dresses
         2,female-tops,"
      end

      let(:schema_string) do
        {
          type: 'record',
          name: 'categories',
          fields: [
            {name: 'id', type: 'int'},
            {name: 'name', type: 'string'},
            {name: 'description', type: ['string','null']}
          ]
        }.to_json
      end

      before do
        input = StringIO.new(input_string)
        schema = StringIO.new(schema_string)

        @io = CSV2Avro::Converter.new(input, schema, StringIO.new, {}).perform
      end

      it 'should work' do
        expect(CSV2Avro::Reader.new(@io).perform).to eq(
          [{"id"=>1, "name"=>"dresses", "description"=>"Dresses"},
           {"id"=>2, "name"=>"female-tops", "description"=>nil}])
      end
    end
  end
end
