require 'baby_squeel/dsl'

module BabySqueel
  module ActiveRecord
    module WhereChain
      # Constructs Arel for ActiveRecord::Base#where using the DSL.
      def has(&block)
        arel = DSL.evaluate(@scope, &block)

        unless arel.blank?
          arel = Operators::Grouping.coerce_boolean_attribute("where.has", arel)

          @scope.where!(arel)
        end

        @scope
      end
    end
  end
end
