module Vissen
  module Input
    # Message Factory
    #
    # The facatory takes raw input messages and builds matching objects around
    # them. It stores a list of input matchers that it knows about.
    class MessageFactory
      def initialize
        @matchers     = []
        @lookup_table = Array.new(16)
      end

      def freeze
        @matchers.freeze
        super
      end

      def add_matcher(matcher)
        raise TypeError unless matcher.is_a? Matcher
        @matchers << matcher
      end

      def build(data, timestamp)
        matcher = @matchers.find { |m| m.match? data }
        
        return nil unless matcher
        matcher.klass.new data, timestamp
      end
      
      private
      
      def add_to_lookup(matcher)
        data = [0, 0, 0]
        @lookup_table.each_with_index do |entry, index|
          data[0] = index << 4
          if matcher.match? data
            if entry
              entry << matcher
            else
              @lookup_table[index] = [matcher]
            end
          end
        end
      end
    end
  end
end
