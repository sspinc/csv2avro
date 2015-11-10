require 'json'

class CSV2Avro
  class Log

    DEBUG = 'DEBUG'
    INFO = 'INFO'
    WARN = 'WARN'
    ERROR = 'ERROR'
    FATAL = 'FATAL'

    def self.puts(message: nil, event: nil, metrics: nil, level: INFO)
      log_item = {
        app: app,
        host: host,
        level: level,
      }
      log_item[:message] = message if message
      log_item[:event] = event.to_hash if event
      output.puts log_item.to_json
    end

    private

    def self.app
      'csv2avro'
    end

    def self.host
      @host ||= `hostname`.strip
    end

    def self.output
      $stdout
    end
  end
end
