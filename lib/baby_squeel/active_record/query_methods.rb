require 'baby_squeel/dsl'
require 'baby_squeel/join_dependency'

module BabySqueel
  module ActiveRecord
    module QueryMethods
      # This class allows BabySqueel to slip custom
      # joins_values into Active Record's JoinDependency
      module Injector6_1
        def each(&block)
          super do |join|
            if join.is_a?(BabySqueel::Join)
              result = block.binding.local_variables.include?(:result) && block.binding.local_variable_get(:result)
              result << join if result
              join
            else
              block.call(join)
            end
          end
        end
      end

      # Constructs Arel for ActiveRecord::QueryMethods#joins using the DSL.
      def joining(&block)
        joins DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#select using the DSL.
      def selecting(&block)
        select DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#order using the DSL.
      def ordering(&block)
        order DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#reorder using the DSL.
      def reordering(&block)
        reorder DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#group using the DSL.
      def grouping(&block)
        group DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#having using the DSL.
      def when_having(&block)
        having DSL.evaluate(self, &block)
      end

      def construct_join_dependency(associations, join_type)
        result = super(associations, join_type)
        if associations.any? { |assoc| assoc.is_a?(BabySqueel::Join) }
          result.extend(BabySqueel::JoinDependency::Injector6_1)
        end
        result
      end

      private

      # https://github.com/rails/rails/commit/c0c53ee9d28134757cf1418521cb97c4a135f140
      def select_association_list(*args)
        if args[0].any? { |join| join.is_a?(BabySqueel::Join) }
          args[0].extend(BabySqueel::ActiveRecord::QueryMethods::Injector6_1)
        end
        super *args
      end
    end
  end
end
