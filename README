framed_rails
------------

`framed_rails` is a gem to add Framed instrumentation to your rails4 app.  For each pageview, it sends an event to Framed.

FIXME: By default it actually current sends to Segment; we still need a Framed endpoint and secret key.

To use this with rails:


 * Add 'framed_rails' to your Gemfile.
 * Add the following to config/initializers/framed_rails.rb:

```
require 'framed_rails'

Framed.configure do |config|
  config[:write_key] = 'your write key'
end
```

Note that the threaded emitter works on a background thread.  It is possible that events will be unreported when your containing process ends, unless you drain at process shutdown, i.e.

```
Framed.drain
```

If reporting fails, the exception will be logged to STDERR by default, unless Rails is detected.  In that case, the `Rails.logger` will be used.


Configuration
-------------

<table>
	<th><td>Key</td><td>Description</td><td><td>Default</td></th>

	<tr><td>:consumer</td><td>The emitter to be used for reporting.  See the Emitters section below.</td><td>Framed::Emitters::Blocking</td></tr>

	<tr><td>:endpoint</td><td>The URL to POST to, using basic auth with your write key</td><td>Framed::SEGMENT_API</td></tr>
	        :user_id_controller_method => 'framed_devise_user_id',

	<tr><td>:logger</td><td>A Logger for reporting errors.</td><td>STDERR, or Rails.logger if detected.</td></tr>

	<tr><td>:anonymous_cookie</td><td>The name of the in signed cookie for anonymous user IDs.  Long-lived anonymous user IDs are issued anonymous users.</td><td>Framed::COOKIE_NAME</td></tr>

	<tr><td>:user_id_controller_method</td><td>The name of a controller method which can provide the current User ID.  Devise just works.</td><td>'framed_devise_user_id'</td></tr>
</table>

Emitters
--------

By default, the report is sent with a blocking Emitter.  If you would prefer a non-blocking emitter, you can include the following line in your configure block:


```
  config[:consumer] => Framed::Emitters::Threaded
```

If you'd like to implement your own, see lib/framed/emitters.rb, particularly Base and Blocking as examples.