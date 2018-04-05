module Vissen
  module Input
    # Message Factory
    #
    # The facatory takes raw input messages and builds matching objects around
    # them. It stores a list of input matchers that it knows about.
    #
    # If an array of matchers is passed to the constructor the MessageFactory
    # will freeze itself to create an immutable factory.
    #
    # TODO: Sort the matchers on input frequency for performance?
    class MessageFactory
      def initialize(matchers = nil)
        @lookup_table = Array.new(16)
        @matchers     = []
        
        if matchers
          matchers.each { |m| add_matcher m }
          freeze
        end
      end

      def freeze
        @matchers.freeze
        super
      end

      # Add Matcher
      #
      # Inserts another matcher to the list of known input data matchers.
      def add_matcher(matcher)
        raise TypeError unless matcher.is_a? Matcher
        @matchers << matcher
      end

      # Build
      #
      # Creates a new Message object by matching the data against the stored
      # message klasses.
      def build(data, timestamp)
        matcher = lookup data
              
        klass = matcher ? matcher.klass : Message::Unknown
        klass.new data, timestamp
      end
      
      private
      
      def lookup(data)
        status  = data[0] >> 4
        matcher = @lookup_table[status]&.find { |m| m.match? data }
        
        unless matcher
          matcher = @matchers.find { |m| m.match? data }
          add_to_lookup matcher, data if matcher
        end
        
        matcher
      end
      
      def add_to_lookup(matcher, data)
        status = data[0] >> 4
        entry  = @lookup_table[status]
        
        if entry
          entry << matcher
        else
          @lookup_table[status] = [matcher]
        end
      end
    end
  end
end
