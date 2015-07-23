require 'securerandom'

begin
  require 'uuid'
rescue LoadError
end

module Framed
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