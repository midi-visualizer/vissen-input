# frozen_string_literal: true

require 'vissen/input/version'

require 'vissen/input/matcher'
require 'vissen/input/message_factory'
require 'vissen/input/subscription'
require 'vissen/input/broker'

require 'vissen/input/message'
require 'vissen/input/message/base'
require 'vissen/input/message/aftertouch'
require 'vissen/input/message/channel_pressure'
require 'vissen/input/message/channel_mode'
require 'vissen/input/message/control_change'
require 'vissen/input/message/note'
require 'vissen/input/message/pitch_bend_change'
require 'vissen/input/message/program_change'
require 'vissen/input/message/unknown'

module Vissen
  # This module includes all the input messages that can be sent to the vissen
  # engine, as well as some facilities for converting them to and from their
  # binary form.
  module Input
  end
end
