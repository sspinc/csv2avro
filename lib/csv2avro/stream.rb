class CSV2Avro
  class Stream
    def initialize
      STDIN.sync = true
    end

    def readline
      buffer = ""
      until buffer[/\n/]
        buffer += STDIN.sysread(1)
      end
      buffer
    rescue EOFError => e
      false
    end

    def each_line
      STDIN.each_line do |line|
        yield line
      end
    end
  end
end
