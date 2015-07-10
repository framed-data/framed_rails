module Framed
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Framed.configure do |config|
        config.logger ||= ::Rails.logger
      end
    end
  end
end
