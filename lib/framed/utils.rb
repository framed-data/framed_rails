require 'securerandom'
require 'time'

begin
  require 'uuid'
rescue LoadError
end

module Framed
  module Utils
    class << self
      def uuid
        begin
          UUID.new.generate
        rescue NameError
          SecureRandom.uuid
        end
      end

      # Adapted from Rails in case it isn't available.
      def try(o, *a, &b)
        try!(o, *a, &b) if a.empty? || o.respond_to?(a.first)
      end

      def try!(o, *a, &b)
        if a.empty? && block_given?
          if b.arity.zero?
            o.instance_eval(&b)
          else
            yield o
          end
        else
          o.public_send(*a, &b)
        end
      end

      def serialize_date(dt)
        dt.utc.iso8601
      end
    end
  end
end