require 'baby_squeel/calculation'

module BabySqueel
  module ActiveRecord
    module Calculations
      def plucking(&block)
        nodes = Array.wrap(DSL.evaluate(self, &block))
        pluck(*nodes)
      end

      def counting(&block)
        count Calculation.new(DSL.evaluate(self, &block))
      end

      def summing(&block)
        sum Calculation.new(DSL.evaluate(self, &block))
      end

      def averaging(&block)
        average Calculation.new(DSL.evaluate(self, &block))
      end

      def minimizing(&block)
        minimum Calculation.new(DSL.evaluate(self, &block))
      end

      def maximizing(&block)
        maximum Calculation.new(DSL.evaluate(self, &block))
      end

      protected

      # @override
      def aggregate_column(column_name)
        if column_name.kind_of? Calculation
          column_name.node
        else
          super
        end
      end
    end
  end
end
