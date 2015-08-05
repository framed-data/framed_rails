module Framed
  class Error < ::StandardError
  end

  class RequiredConfiguration < Error
  end

  class Timeout < Error
  end
end