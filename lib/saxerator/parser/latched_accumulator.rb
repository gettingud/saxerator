module Saxerator
  module Parser
    class LatchedAccumulator < ::Saxerator::SaxHandler
      def initialize(config, latches, block)
        @latches = latches
        @accumulator = Accumulator.new(config, block)
        @ignore_namespaces = config.ignore_namespaces?
      end

      def check_latches_and_passthrough(method, *args)
        @latches.each { |latch| latch.send(method, *args) }
        if @accumulator.accumulating? ||
            @latches.all? { |latch| latch.open? }
          @accumulator.send(method, *args)
        end
      end

      def start_element(name, attrs = [])
        check_latches_and_passthrough(:start_element, name, attrs)
      end

      def end_element(name)
        check_latches_and_passthrough(:end_element, name)
      end

      def characters(string)
        check_latches_and_passthrough(:characters, string)
      end
    end
  end
end
