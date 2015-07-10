require 'framed_rails'

Framed.configure do |config|
  config[:write_key] = 'XWkzILLq5gLUKXQUhAl4DJej1wkxqiBy'
#  config[:consumer] = Framed::Blocking
end

data = { 
  anonymousId: "anon1",
  userId: "user1",
  event: "signup",
  properties: {
    name: "value"
  }
}

Framed.report(data) 