require 'securerandom'

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
    end
  end
end