# Stackprofiler

Stackprofiler is a web UI wrapper for the excellent [`stackprof`][1]
sampling call-stack profiler for Ruby 2.1+. `stackprof` features a
command-line tool that is very handy for inspecting hotspots in code,
but seeing the "bigger picture" can be difficult without a GUI to
click around in. Hence: Stackprofiler.

There already exist gems in this vein. Most (all?) are based on
[`rubyprof`][2], an instrumenting profiler for Ruby 1.9.3+.
Unfortunately, in my experience RubyProf has an unacceptably
high overhead when profiling already-slow code and this makes
profiling very frustrating, if not useless. Maybe I'm holding it
wrong, but `stackprof` seems much more useful.

Stackprofiler is in an **incredibly early** state of development. The
only reason it has been published this early is as supporting evidence
for a job application! Please keep that in mind when you find all the
rough edges :)

![Screenshot](http://i.imgur.com/8UJV9Oo.png)
![Screenshot](http://i.imgur.com/57Oe4Bl.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stackprofiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stackprofiler

## Middleware

Using Stackprofiler at this stage is pretty simple on account of there
not yet being much flexibility in the way of configuration. This will be
fixed later - hopefully the simplicity can remain.

Once installed, add Stackprofiler's middleware somewhere in your Rack
chain, e.g.:

    config.middleware.use Stackprofiler::Middleware

Now start your server like normal. If you wish to profile a request,
append `profile=true` to the query string. This will inform Stackprofiler
that it should do its thing. Take note that the response will remain
unchanged - Stackprofiler will record its statistics for your later perusal
elsewhere. This is to make it easier to profile requests that don't return
visible results, e.g. XHR.

Once you have profiled a request or two, you can head over to Stackprofiler's
GUI. This is located on the same port as your website, albeit at the
path `/__stackprofiler`. If your server is running on port 5000 in development,
the link might be [`http://localhost:5000/__stackprofiler`](http://localhost:5000/__stackprofiler).

You should now see a page that looks like the screenshot above. Click on any
line in the stack trace to see the code for that method annotated with the
performance characteristics for each line. I would document those here but
they are going to change in the next few dev hours, so I'll come back to that
later.

### Data collection configuration

Stackprofiler's operation can be configured by passing in parameters to the
middleware specified above. While the defaults should suit most applications,
changing them is easy enough:

```ruby
config.middleware.use Stackprofiler::Middleware {
  predicate: /profile=true/, # regex form for urls to be profiled
  predicate: proc {|env| true }, # callable form for greater flexibility than regex
  stackprof: { # options to be passed directly through to stackprof, e.g.:
    interval: 1000 # sample every n micro-seconds
  }
}
```

## Ad hoc

Sometimes you want to test some code that isn't part of a Rack app - or is
just cumbersome to run outside of an IRB console. You can test this code
directly using code very similar to the `stackprof` interface. It works like
this:

Run `$ stackprofiler` from the command line. This will start a Stackprofiler
server that will listen for incoming profile runs and display them on
[`http://localhost:9292/__stackprofiler`](http://localhost:9292/__stackprofiler).
Next, in an IRB console (or, even better, [Pry][3]!)

```ruby
require 'stackprofiler'

Stackprofiler.profile do
  SomeSlowTaskThatNeedsInvestigation.run
end
```

Now visit the above URL and a visual breakdown of the code flow will be visible.

## Contributing

1. Fork it ( https://github.com/glassechidna/stackprofiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO

So much. First todo: write a todo list.

[1]: https://github.com/tmm1/stackprof
[2]: https://github.com/ruby-prof/ruby-prof
[3]: https://github.com/pry/pry
