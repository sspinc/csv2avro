module Log
  class Event

    def initialize(name,  context, monitored: false)
      @name = name
      @monitored = monitored
      @context = context
    end

    def to_hash
      { name: @name, monitored: @monitored }.merge(@context)
    end
  end
end
