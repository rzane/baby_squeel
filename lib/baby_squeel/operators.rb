module BabySqueel
  module Operators
    module ArelAliasing
      # Allows the creation of shorthands for Arel methods.
      #
      # ==== Arguments
      #
      # * +operator+ - A custom operator.
      # * +arel_name+ - The name of the Arel method you want to alias.
      #
      # ==== Example
      #    BabySqueel::Nodes::Node.arel_alias :unlike, :does_not_match
      #    Post.where.has { title.unlike 'something' }
      #
      def arel_alias(operator, arel_name)
        define_method operator do |other|
          send(arel_name, other)
        end
      end
    end

    module Comparison
      extend ArelAliasing
      arel_alias :<, :lt
      arel_alias :>, :gt
      arel_alias :<=, :lteq
      arel_alias :>=, :gteq
    end

    module Equality
      extend ArelAliasing
      arel_alias :==, :eq
      arel_alias :'!=', :not_eq
    end

    module Generic
      # Create a SQL operation. See Arel::Nodes::InfixOperation.
      #
      # ==== Arguments
      #
      # * +operator+ - A SQL operator.
      # * +other+ - The argument to be passed to the SQL operator.
      #
      # ==== Example
      #    Post.selecting { title.op('||', quoted('diddly')) }
      #    #=> SELECT "posts"."title" || 'diddly' FROM "posts"
      #
      def op(operator, other)
        Nodes.wrap Arel::Nodes::InfixOperation.new(operator, self, other)
      end
    end

    module Grouping
      extend ArelAliasing

      def self.coerce_boolean_attribute(op, node)
        return node unless node.is_a?(Arel::Attributes::Attribute)

        unless node.type_caster.type == :boolean
          raise ArgumentError, "non-boolean attribute #{node.name} passed to #{op}"
        end

        Arel::Nodes::Equality.new(node, Arel::Nodes::True.new)
      end

      def &(other)
        self.and(Grouping.coerce_boolean_attribute(:&, other))
      end

      def |(other)
        self.or(Grouping.coerce_boolean_attribute(:|, other))
      end
    end

    module Matching
      extend ArelAliasing
      arel_alias :=~, :matches
      arel_alias :'!~', :does_not_match
      arel_alias :like, :matches
      arel_alias :not_like, :does_not_match
      arel_alias :like_any, :matches_any
      arel_alias :not_like_any, :does_not_match_any
    end
  end
end
