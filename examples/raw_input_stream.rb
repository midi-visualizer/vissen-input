# frozen_string_literal: true

require 'benchmark'
require 'vissen/input'
include Vissen::Input

# First we setup a message factory and a broker.
factory = Message::Base.factory

# We then define the message generation process.
stream_generator = proc { [rand(0..255), rand(0..127), 0] }

T = 4.2
N = 100_000

puts 'Benchmark results:'

res =
  Benchmark.bm(10, 'Real') do |x|
    # We measure just the random message generation as a
    # baseline.
    bl = x.report('Baseline') do
      N.times { stream_generator.call }
    end

    # We then let the factory build N messages from the
    # random message stream.
    fa = x.report('Factory') do
      N.times { factory.build(stream_generator.call, T) }
    end

    # We remove the baseline from the result.
    re = fa - bl

    [re]
  end

puts
puts format('%.2f us per message', res.last.utime * (1_000_000 / N))
puts format('%.0f messages per second', N / res.last.utime)
