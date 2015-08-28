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
        return unless events && events.length > 0

        begin
          @client.track(events)
        rescue Exception => exc
          Framed.log_error("#transmit failed: #{exc}")
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
        Framed.log_info(JSON.generate(event))
      end
    end

    class Blocking < Base
      def start
      end
      def stop(drain = false)
      end
      def enqueue(event)
        transmit([event])
      end
    end

    class Buffered < Base
      MAX_REQUEST_BATCH_SIZE = 100
      MAX_QUEUE_SIZE = 10_000

      def initialize(client)
        super
        @event_queue = Queue.new
        @batch_lock = Mutex.new

        @request_queue = Queue.new
        @request_pending = Mutex.new

        @request_thread = nil
      end

      def start
        if @request_thread and !@request_thread.alive?
          Framed.log_info("Starting request thread due to dead thread")
        end

        @request_thread = Thread.new do
          while true
            pending = @request_queue.pop

            @request_pending.synchronize do
              transmit(pending)
            end

            start_request
          end
        end
      end

      def stop(drain = false)
        if drain
          # start batch requests if needed
          while @event_queue.length > 0
            start_request
          end

          # wait for pending requests if needed:
          while @request_queue.length > 0
            sleep(0.1)
          end

          # and wait for the final request, if needed
          @request_pending.synchronize do
            stop_request_thread
          end
        else
          stop_request_thread
        end
      end

      def warn_full(event)
        Framed.log_error("Queued #{event} to Framed, but queue is full. Dropping event.")
      end

      def enqueue(event)
        queue_full = false
        @batch_lock.synchronize do
          # To avoid logging inside the lock (since loggers can block)
          #  we remember if the queue is full and log outside the lock.
          queue_full = @event_queue.length >= MAX_QUEUE_SIZE

          if !queue_full
            @event_queue << event
          end

          # don't start a new request if one is already in progress.
          if @request_pending.locked?
            return
          end
        end

        warn_full if queue_full

        start_request
      end

      private

      def ensure_request_thread
        return if @request_thread && @request_thread.alive?

        @request_pending.synchronize do
          start
        end
      end

      def stop_request_thread
        if @request_thread
          @request_thread.kill
          @request_thread = nil
        end
      end

      def start_request
        ensure_request_thread

        @batch_lock.synchronize do
          return if @event_queue.empty?

          pending = []
          while pending.length < MAX_REQUEST_BATCH_SIZE && @event_queue.length > 0
             pending << @event_queue.pop
          end

          @request_queue << pending
        end
      end

      def transmit(events)
        return unless events && events.length > 0

        begin
          @client.track(events)
        rescue Exception => exc
          Framed.log_error("#transmit failed: #{exc}")
        end
      end
    end
  end
end
