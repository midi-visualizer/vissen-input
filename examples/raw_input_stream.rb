# frozen_string_literal: true

require 'benchmark'
require 'vissen/input'
include Vissen::Input

T = 4.2
N = 100_000

# First we setup a broker.
broker = Broker.new

Counter = Struct.new :count do
  def call(_, _)
    self.count += 1
  end

  def result
    self.count.to_f / N * 100
  end
end

counter = Counter.new 0

# Subscribe to some messages
broker.subscribe(Message::Note[5, 1],        counter)
broker.subscribe(Message::ControlChange[8],  counter)
broker.subscribe(Message::ProgramChange[15], counter)
broker.subscribe(Message::PitchBendChange,   counter)
broker.subscribe(Message::Aftertouch,        counter)

# We then define the message generation process.
stream_generator = proc { [rand(0..255), rand(0..127), 0] }

puts 'Benchmark results:'

res =
  Benchmark.bm(10, 'Real') do |x|
    # We measure just the random message generation as a
    # baseline.
    bl = x.report('Baseline') do
      N.times { { data: stream_generator.call, timestamp: T } }
    end

    # We then let the factory build N messages from the
    # random message stream.
    fa = x.report('Factory') do
      N.times do
        broker.publish(data: stream_generator.call, timestamp: T)
        broker.run_once
      end
    end

    # We remove the baseline from the result.
    re = fa - bl

    [re]
  end

puts
puts format('%d messages processed (%0.1f%%)', counter.count, counter.result)
puts format('%.2f us per message', res.last.utime * (1_000_000 / N))
puts format('%.0f messages per second', N / res.last.utime)
