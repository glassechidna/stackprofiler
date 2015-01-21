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
![Screenshot](http://i.imgur.com/CsZMXLu.png)

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

Stackprofiler can be used to measure the performance of Ruby-powered websites
by using a drop-in Rack middleware. This middleware is provided by a separate
gem; [`stackprofiler-middleware`][3].

The reason for a separate gem is so that Stackprofiler can be used in as many
circumstances as possible. Your app may have dependencies that conflict with
those powering the Stackprofiler web UI and it would be a shame to miss out
on using this tool on account of that.

Head on over to the README for that gem to learn how to use it.

## Pry Plugin

Sometimes you want to test some code that isn't part of a Rack app - or is
just cumbersome to run outside of an IRB console. You can test this code
directly very easily using the [`pry-stackprofiler`][4] gem in the [Pry][5]
REPL.

Pry is an alternative to IRB with handy support for plugins. `pry-stackprofiler`
is such a plugin and works well with the Stackprofiler server. Once installed,
you can type code into the REPL like:

```ruby
Pry.profile do
  sleep 0.3
  sleep 0.4
  sleep 0.1
end
```

And the profile results will appear in the Stackprofiler web UI. For running
instructions, refer to the gem's README.

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
[3]: https://github.com/glassechidna/stackprofiler-middleware
[4]: https://github.com/glassechidna/pry-stackprofiler
[5]: https://github.com/pry/pry
