require 'json'

class CSV2Avro
  class Event

    def initialize(name, monitored=false, context={})
      @name = name
      @monitored = monitored
      @context = context
    end

    def to_hash
      { name: @name, monitored: @monitored }.merge(@context)
    end
  end
end
