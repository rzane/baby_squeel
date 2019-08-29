require 'baby_squeel/dsl'
require 'baby_squeel/join_dependency'

module BabySqueel
  module ActiveRecord
    module QueryMethods
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

      private

      # This is a monkey patch, and I'm not happy about it.
      # Active Record will call `group_by` on the `joins`. The
      # Injector has a custom `group_by` method that handles
      # BabySqueel::Join nodes.
      def build_joins(*args)
        args[1] = BabySqueel::JoinDependency::Injector.new(args.second)

        super *args
      end
    end
  end
end
