require 'baby_squeel/nodes/node'

module BabySqueel
  module Nodes
    class Attribute < Node
      def initialize(parent, name)
        @parent = parent
        @name = name.to_s
        super(parent._table[@name])
      end

      def &(other)
        boolean_binary_operator(:&, :and, other)
      end

      def |(other)
        boolean_binary_operator(:|, :or, other)
      end

      def in(rel)
        if rel.is_a? ::ActiveRecord::Relation
          Nodes.wrap ::Arel::Nodes::In.new(self, sanitize_relation(rel))
        else
          super
        end
      end

      def not_in(rel)
        if rel.is_a? ::ActiveRecord::Relation
          Nodes.wrap ::Arel::Nodes::NotIn.new(self, sanitize_relation(rel))
        else
          super
        end
      end

      def _arel
        if @parent.kind_of?(BabySqueel::Association) && !@parent.alias?
          @parent.find_alias[@name]
        else
          super
        end
      end

      private

      def boolean_binary_operator(operator, arel_method, other)
        lhs = Operators::Grouping.coerce_boolean_attribute(operator, self)
        rhs = Operators::Grouping.coerce_boolean_attribute(operator, other)

        lhs.send(arel_method, rhs)
      end

      # NullRelation must be treated as a special case, because
      # NullRelation#to_sql returns an empty string. As such,
      # we need to convert the NullRelation to regular relation.
      # Conveniently, this approach automatically adds a 1=0.
      # I have literally no idea why, but I'll take it.
      def sanitize_relation(rel)
        if ::ActiveRecord::VERSION::MAJOR < 7 && rel.kind_of?(::ActiveRecord::NullRelation)
          other = rel.spawn
          other.extending_values -= [::ActiveRecord::NullRelation]
          sanitize_relation rel.unscoped.merge(other)
        else
          Arel.sql rel.to_sql
        end
      end
    end
  end
end
