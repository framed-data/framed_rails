module Framed
  class Error < ::StandardError
  end

  class RequiredConfiguration < Error
  end
end