excon_path = ::File.expand_path('../../../vendor/gems/excon-0.45.3/lib/', __FILE__)
require File.join(excon_path, 'excon')
require 'base64'
require 'json'

require 'framed/exceptions'

module Framed
  class Client
    attr_accessor :config

    def initialize(config)
      raise Error.new('No API endpoint specified') unless config[:endpoint]
      raise Error.new('No write_key specified') unless config[:write_key]

      @config = config
    end

    def track(data)
      write_key = Base64.strict_encode64(@config[:write_key])
      Excon.post(@config[:endpoint],
        :headers => {
          'Authorization' => "Basic #{write_key}",
          'Content-Type' => 'application/json'
        },
        :body => JSON.generate(data)
      )
    end
  end
end
