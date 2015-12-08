`framed_rails`
------------

`framed_rails` is a gem to add Framed instrumentation to your Rails 4
app. For each request that occurs in your app, it sends an event to Framed for analysis.

To use this in your Rails project:

 * Add `gem 'framed_rails', '~> 0.1.7'` to your Gemfile.
 * Add the following to `config/initializers/framed_rails.rb`:

```ruby
require 'framed_rails'

Framed.configure do |config|
  config[:api_key] = 'YOUR_FRAMED_API_KEY'
end
```

If request reporting fails, an exception will be logged to `Rails.logger` by default.
The logger used can be customized in config.

Configuration
-------------

<table>
	<tr>
    <th>Key</th>
    <th>Description</th>
    <th>Default</th>
  </tr>

  <tr>
    <td><code>:emitter</code></td>
    <td>The emitter to be used for reporting. See the Emitters
    section below.</td>
    <td><code>Framed::Emitters::Blocking</code></td>
  </tr>

  <tr>
    <td><code>:user_id_controller_method</code></td>
    <td>The name of a controller method which returns id of the current user, if
    any</td>
    <td><code>'framed_current_user_id'</code> (tries <code>current_user.id</code>)</td>
  </tr>

	<tr>
    <td><code>:logger</code></td>
    <td>A Logger for reporting errors.</td>
    <td><code>Rails.logger</code></td>
  </tr>

	<tr>
    <td><code>:anonymous_cookie</code></td>
    <td>The name of the signed cookie for anonymous user IDs.
    Long-lived anonymous user IDs are issued anonymous IDs by default.</td>
    <td><code>Framed::COOKIE_NAME</code></td>
  </tr>

  <tr>
    <td><code>:include_xhr</code></td>
    <td>Whether to include requests sent via AJAX. (Turbolinks are always included.)</td>
    <td>false</td>
  </tr>

  <tr>
    <td><code>:excluded_params</code></td>
    <td>An array of request parameter keys to never send to Framed. <code>:controller</code>, <code>:action</code>,
    <code>:utf8</code>, <code>:authenticity_token</code>, <code>:commit</code>, and <code>:password</code> are never
    sent, and anything added here is in addition to default values.
    </td>
    <td>[]</td>
  </tr>

</table>


user_id_controller_method
--------
This function is used to get the ID of the current user (if any) for properly attributing
events to the users who performed them. The default implementation effectively tries to read
`current_user.id`, but will not fail if `current_user` is not defined. You can change this
to a to a controller function of your choosing by specifying its name as a string (invoked via `send`).


Emitters
--------

By default, events are sent with a blocking emitter, which sends each request to Framed
as it happens. If you would prefer a non-blocking emitter, you can include the following line in
your configure block:


```ruby
config[:emitter] = Framed::Emitters::Buffered
```

Emitters included in this gem:

 * `Framed::Emitters::Blocking` - Logs each request to Framed using a single blocking request (default)
 * `Framed::Emitters::Buffered` - Logs to Framed 1) if no request is in progress, immediately 2) otherwise in batches of up to 100 as soon as the previous request completes.  All requests are sent on a background thread.
 * `Framed::Emitters::InMemory` - stores reported events in memory,
   rather than transmitting them.  Events are later available as `Framed.emitter.reported`.
 * `Framed::Emitters::Logger` - Logs an info message to `config[:logger]`.

Both `InMemory` and `Logger` should be considered for debugging/diagnostic purposes only.

Note that the `Buffered` emitter works on a background thread. It is
possible that events will be unreported when your containing process
ends, unless you explicitly call `#drain` at process shutdown, i.e.

```ruby
Framed.drain
```
