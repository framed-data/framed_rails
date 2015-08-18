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

      def transmit(events)
        return unless events && 0 < events.size

        begin
          @client.track(events)
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
        @batch_lock = Mutex.new
      end

      def enqueue(event)
        @batch_lock.synchronize do
          @queue << event
        end
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

        if drain && @queue.length > 0
          process_events
        end
      end

      private

      def dequeue(limit=10)
        # De-queue up to `limit` events, without blocking.
        #  When limit is met, or when ThreadError occurs
        #  due to trying to dequeue an empty Queue,
        #  return the batch of events.
        @batch_lock.synchronize do
          pending = []
          begin
            while pending.size < limit
              pending << @queue.pop(true)
            end
          rescue ThreadError => exc
            # expected, just return pending
          end
          pending
        end
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
        transmit([event])
      end
    end
  end
end
