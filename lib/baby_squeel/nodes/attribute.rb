require 'baby_squeel/nodes/node'

module BabySqueel
  module Nodes
    class Attribute < Node
      def initialize(parent, name)
        @parent = parent
        @name = name.to_s
        super(parent._table[@name])
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

      def sanitize_relation(rel)
        Arel.sql(rel.to_sql)
      end
    end
  end
end
