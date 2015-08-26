require 'securerandom'
require 'time'

begin
  require 'uuid'
rescue LoadError
end

module Framed
  module Utils
    extend self

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

    def flattened_hash(h, namespace = '', memo = {})
      h.reduce(memo) { |memo, (key, value)|
        value = value.to_h if value.respond_to?(:to_h)
        if value.instance_of?(Hash)
          memo.merge!(flattened_hash(value, "#{namespace}#{key}_", memo))
        else
          memo["#{namespace}#{key}"] = value
        end
        memo
      }
    end
  end
end
