require 'thread'
require 'json'

module Framed
  module Emitters
    class Base
      def initialize(client)
        @client = client
      end

      def stop(drain = false)

      end
      def start

      end

      def enqueue(event)
        raise NotImplementedError
      end

      private

      def transmit(event)
        begin
          @client.track(event)
        rescue StandardError => exc
          Framed.logger.error("framed_rails: transmit failed: #{exc}")
        end
      end
    end

    class InMemory < Base
      attr_reader :reported

      def initialize(client)
        super
        @reported = []
      end

      def enqueue(event)
        @reported << event
      end
    end

    class Logger < Base
      def enqueue(event)
        Framed.logger.info(JSON.generate(event))
      end
    end

    class Threaded < Base
      def initialize(client)
        super
        @queue = Queue.new
      end

      def enqueue(event)
        @queue << event
        start
      end

      def start
        return if @thread

        @thread = Thread.new do
          while true
            begin
              process_events
            rescue StandardError => exc
              Framed.logger.error("framed_rails: run_thread failed: #{exc}")
              stop
            end
            sleep(0.5)
          end
        end
      end

      def stop(drain = false)
        if @thread
          @thread.kill
        end
        @thread = nil

        if drain && @queue.length
          process_events
        end
      end

      private

      def dequeue
        @queue.pop
      end

      def process_events
        while @queue.length > 0
          transmit(dequeue)
        end
      end
    end

    class Blocking < Base
      def start
      end
      def stop
      end
      def enqueue(event)
        transmit(event)
      end
    end
  end
end
