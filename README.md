# 🥀 Vissen Input

[![Gem Version](https://badge.fury.io/rb/vissen-input.svg)](https://badge.fury.io/rb/vissen-input)
[![Build Status](https://travis-ci.org/midi-visualizer/vissen-input.svg?branch=master)](https://travis-ci.org/midi-visualizer/vissen-input)
[![Inline docs](http://inch-ci.org/github/midi-visualizer/vissen-input.svg?branch=master)](http://inch-ci.org/github/midi-visualizer/vissen-input)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/vissen-input/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vissen-input'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vissen-input

## Usage

```ruby
include Vissen::Input

# First we setup a broker.
broker = Broker.new

# We then subscribe to a message type and provide a callback.
broker.subscribe Message::Note[0] do |msg|
    play msg.note if msg.on?
end

# We simulate a raw note on message arriving to the broker
# at time 4.2.
broker.publish data: [0x90, 42, 0], timestamp: 4.2

# Finally we let the broker process the next message in its
# queue. The callback should now have been called.
broker.run_once
```

Please see the [documentation](http://www.rubydoc.info/gems/vissen-input/) for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midi-visualizer/vissen-input.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
