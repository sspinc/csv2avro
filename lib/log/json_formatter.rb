require 'json'

module Log
  class JSONFormatter

    def initialize(appname)
      @appname = appname
    end

    def call(severity, time, progname, msg)
      log_item = {
        host: host,
        app: @appname,
        level: severity,
      }
      log_item[:message] = msg[:message] if msg[:message]
      log_item[:event] = msg[:event].to_hash if msg[:event]
      log_item[:metrics] = msg[:metrics].map { |metric| metric.to_hash } if msg[:metrics]

      log_item.to_json + "\n"
    end

    private

    def host
      @host ||= `hostname`.strip
    end

  end
end
