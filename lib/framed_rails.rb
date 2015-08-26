# encoding: utf-8
require 'logger'

require 'framed/version'
require 'framed/rails' if defined?(::Rails)
require 'framed/railtie' if defined?(::Rails::Railtie)
require 'framed/client'
require 'framed/emitters'
require 'framed/utils'

module Framed
  SEGMENT_API_ENDPOINT = 'https://api.segment.io/v1/track'
  FRAMED_API_ENDPOINT = 'https://intake.framed.io/events'
  COOKIE_NAME = 'framed_id'

  class << self
    attr_accessor :client, :consumer

    def configuration
      @configuration ||= {
        :consumer => Framed::Emitters::Blocking,
        :user_id_controller_method => 'framed_devise_user_id',
        :endpoint => Framed::FRAMED_API_ENDPOINT,
        :logger => Logger.new(STDERR),
        :anonymous_cookie => Framed::COOKIE_NAME
      }
    end

    def configure(silent = false)
      yield configuration
      self.client = Client.new(configuration)

      @consumer.stop(true) if @consumer
      @consumer = configuration[:consumer].new(self.client)
    end

    def report(event)
      event[:lib] =  "framed_ruby"
      event[:lib_version] = Framed::VERSION
      event[:type] ||= :track
      event[:context] ||= {}
      event[:context].merge!({
        :channel => 'server',
      })

      event[:properties] ||= {}

      # fill in if needed, in case it sits in queue for a while.
      event[:timestamp] ||= Framed::Utils.serialize_date(Time.now)
      @consumer.enqueue(event)
    end

    def logger
      configuration[:logger]
    end

    def drain    
      @consumer.stop(true) if @consumer
    end

    def user_id_controller_method
      configuration[:user_id_controller_method]
    end

    def anonymous_cookie
      configuration[:anonymous_cookie]
    end

    def new_anonymous_id
      Framed::Utils.uuid
    end
  end
end
