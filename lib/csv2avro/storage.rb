require 'aws-sdk'
require 'uri'

class CSV2Avro
  class Storage
    attr_reader :uri

    def initialize(path)
      @uri = URI(path)
    end

    def read
      case uri.scheme
      when 's3'
        s3 = Aws::S3::Client.new(region: 'us-east-1')
        resp = s3.get_object(bucket: uri.host, key: uri.path)

        resp.body
      else
        File.open(uri.path, 'r')
      end
    end
  end
end
