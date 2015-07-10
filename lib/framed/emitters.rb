module Framed
  class Base
    def initialize(client)
      @client = client
    end

    def stop(drain = false)

    end
    def start

    end

    def enqueue
      raise NotImplementedError
    end
  end

  class Threaded < Base
    def initialize(client)
      super
      @queue = []
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
            logger.error("framed_rails: run_thread failed: #{exc}")
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

      if drain && @queue.count
        process_events
      end      
    end

    private

    def dequeue
      @queue.pop
    end

    def process_events
      while @queue.count > 0
        event = dequeue
  
        begin
          @client.track(event)
        rescue Framed::Error => exc
          logger.warn("WTFBBQ #{exc}")
        end
      end
    end
  end

  class Blocking < Base
    def start
    end
    def stop
    end
    def enqueue(event)
      @client.track(event)
    end
  end
end
