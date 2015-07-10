# encoding: utf-8
require 'logger'
require 'time'

require 'framed/version'
require 'framed/railtie' if defined?(::Rails::Railtie)
require 'framed/client'
require 'framed/emitters'

module Framed
  SEGMENT_API = 'https://api.segment.io/v1/track'

  class << self
    attr_accessor :client, :consumer

    def configuration
      @configuration ||= {
        :consumer => Framed::Threaded,
        :user_controller_method => 'current_user',
        :endpoint => Framed::SEGMENT_API,
        :logger => Logger.new(STDERR)
      }
    end

    def configure(silent = false)
      yield configuration
      self.client = Client.new(configuration)

      @consumer.stop if @consumer
      @consumer = configuration[:consumer].new(self.client)
    end

    def report(event)
      event[:context] ||= {}
      event[:context].merge!({
        :library => {
          :name => "framed_rails",
          :version => Framed::VERSION
        }
      })

      # fill in if needed, in case it sits in queue for a while.
      event[:timestamp] ||= Time.now.utc.iso8601

      @consumer.enqueue(event)
    end

    def logger
      @config[:logger]
    end

    def drain
      @consumer.stop(true)
    end
  end
end
