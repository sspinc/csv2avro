require 'aws-sdk'
require 'uri'

class CSV2Avro
  class Storage
    attr_reader :uri

    def initialize(uri)
      @uri = URI(uri)
    end

    def open
      case uri.scheme
      when 's3'
        s3 = Aws::S3::Client.new
        resp = s3.get_object(bucket: uri.host, key: uri.path[1..-1])

        resp.body
      when 'file'
        File.open(uri.path, 'r')
      else
        raise Exception.new("Unsupported schema on read: '#{uri}'")
      end
    end

    def write(string)
      case uri.scheme
      when 's3'
        s3 = Aws::S3::Client.new
        md5 = Digest::MD5.base64digest(string)
        s3.put_object(bucket: uri.host, key: uri.path[1..-1], body: string, content_md5: md5)
      when 'file'
        File.write(uri.path, string)
      else
        raise Exception.new("Unsupported schema on write: '#{uri}'")
      end
    end
  end
end
