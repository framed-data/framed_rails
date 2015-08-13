require 'excon'
require 'base64'
require 'json'

require 'framed/exceptions'

module Framed
  class Client
    attr_accessor :config

    def initialize(config)
      raise Error.new('No API endpoint specified') unless config[:endpoint]
      raise Error.new('No api_key specified') unless config[:api_key]

      @config = config
    end

    def track(data)
      creds = Base64.strict_encode64(@config[:api_key] + ':')
      payload = JSON.generate(data)
      response = Excon.post(@config[:endpoint],
        :headers => {
          'Authorization' => "Basic #{creds}",
          'Content-Type' => 'application/json'
        },
        :body => payload
      )

      if response.status != 200
        raise Framed::RequestError.new("Failed Client.track #{response.status} with data #{payload}")
      end
    end
  end
end
