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
        resp = s3.get_object(bucket: uri.host, key: uri.path[1..-1])

        resp.body
      else
        File.open(uri.path, 'r')
      end
    end

    def write(io)
      case uri.scheme
      when 's3'
        s3 = Aws::S3::Client.new(region: 'us-east-1')
        md5 = Digest::MD5.base64digest(io.string)
        s3.put_object(bucket: uri.host, key: uri.path[1..-1], body: io, content_md5: md5)
      else
        File.write(uri.path, io.string)
      end
    end
  end
end
