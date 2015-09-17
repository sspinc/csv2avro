require 'json'

class CSV2Avro
  class Log

    DEBUG = 'DEBUG'
    INFO = 'INFO'
    WARN = 'WARN'
    ERROR = 'ERROR'
    FATAL = 'FATAL'

    def self.puts(message:, event: nil, metrics: nil, level: INFO)
      log_item = {
        app: app,
        host: host,
        level: level,
        message: message,
      }.to_json
      output.puts log_item
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
