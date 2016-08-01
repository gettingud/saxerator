module Saxerator
  module Parser
    class Accumulator < ::Saxerator::SaxHandler
      def initialize(config, block)
        @stack = []
        @config = config
        @block = block
        @builder = Builder.to_class(@config.output_type)
      end

      def start_element(name, attrs = [])
        @stack.push @builder.new(@config, name, Hash[*attrs.flatten])
      end

      def end_element(_)
        if @stack.size > 1
          last = @stack.pop
          @stack.last.add_node last
        else
          @block.call(@stack.pop.block_variable)
        end
      end

      def characters(string)
        @stack.last.add_node(string) unless string.strip.empty?
      end

      def accumulating?
        !@stack.empty?
      end
    end
  end
end
