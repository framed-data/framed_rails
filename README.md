`framed_rails`
------------

`framed_rails` is a gem to add Framed instrumentation to your Rails 4
app. For each request, it sends an event to Framed.

To use this in your Rails project:

 * Add `gem 'framed_rails', '~> 0.1.4'` to your Gemfile.
 * Add the following to `config/initializers/framed_rails.rb`:

```ruby
require 'framed_rails'

Framed.configure do |config|
  config[:api_key] = 'YOUR_FRAMED_API_KEY'
end
```

If reporting fails, the exception will be logged to `Rails.logger` by default.

Configuration
-------------

<table>
	<tr>
    <th>Key</th>
    <th>Description</th>
    <th>Default</th>
  </tr>

  <tr>
    <td>:consumer</td>
    <td>The emitter to be used for reporting.  See the Emitters
    section below.</td>
    <td>`Framed::Emitters::Blocking`</td>
  </tr>

  <tr>
    <td>:user_id_controller_method</td>
    <td>The name of a controller method which returns the user ID, if
    any</td>
    <td>`framed_current_user_id`</td>
  </tr>

	<tr>
    <td>:logger</td>
    <td>A Logger for reporting errors.</td>
    <td>`Rails.logger`</td>
  </tr>

	<tr>
    <td>:anonymous_cookie</td>
    <td>The name of the in signed cookie for anonymous user IDs.
    Long-lived anonymous user IDs are issued anonymous users.</td>
    <td>`Framed::COOKIE_NAME`</td>
  </tr>

	<tr>
    <td>:user_id_controller_method</td>
    <td>The name of a controller method which can provide the current
    User ID. (Also works with Devise).</td>
    <td>'framed_current_user_id'</td>
  </tr>

  <tr>
    <td>:include_xhr</td>
    <td>Whether to include requests sent via AJAX. (Turbolinks are always included.)</td>
    <td>false</td>
  </tr>

</table>

Emitters
--------

By default, events are sent with a blocking emitter, which sends each request to Framed
as it happens. If you would prefer a non-blocking emitter, you can include the following line in
your configure block:


```ruby
config[:consumer] = Framed::Emitters::Buffered
```

Emitters included in this gem:

 * `Framed::Emitters::Blocking` - Logs each request to Framed using a single blocking request (default)
 * `Framed::Emitters::Buffered` - Logs to Framed 1) if no request is in progress, immediately 2) otherwise in batches of up to 100 as soon as the previous request completes.  All requests are sent on a background thread.
 * `Framed::Emitters::InMemory` - stores reported events in memory,
   rather than transmitting them.  Events are later available as `Framed.consumer.reported`.
 * `Framed::Emitters::Logger` - Logs an info message to `config[:logger]`.

Both `InMemory` and `Logger` should be considered for debugging/diagnostic purposes only.

Note that the `Buffered` emitter works on a background thread. It is
possible that events will be unreported when your containing process
ends, unless you explicitly call `#drain` at process shutdown, i.e.

```ruby
Framed.drain
```
