require 'baby_squeel/active_record/version_helper'

module BabySqueel
  module JoinDependency
    # This class allows BabySqueel to slip custom
    # joins_values into Active Record's JoinDependency
    class Injector6_0 < Array # :nodoc:
      # https://github.com/rails/rails/pull/36805/files
      # This commit changed group_by to each
      def each(&block)
        super do |join|
          if block.binding.local_variables.include?(:buckets)
            buckets = block.binding.local_variable_get(:buckets)

            case join
            when BabySqueel::Join
              buckets[:association_join] << join
            else
              block.call(join)
            end
          else
            block.call(join)
          end
        end
      end
    end

    # This is a 'fix' for the left outer joins
    # rails way would be to call left_outer_joins so the join_type gets set to Arel::Nodes::OuterJoin
    # Maybe this could be fixed in joining but I do not know how.
    module Injector6_1 # :nodoc:
      def make_constraints(parent, child, join_type) # :nodoc:
        join_type = child.join_type if child.join_type == Arel::Nodes::OuterJoin
        super(parent, child, join_type)
      end
    end

    class Builder # :nodoc:
      attr_reader :join_dependency

      def initialize(relation)
        @join_dependency = build(relation, collect_joins(relation))
      end

      # Find the alias of a BabySqueel::Association, by passing
      # a list (in order of chaining) of associations and finding
      # the respective JoinAssociation at each level.
      def find_alias(associations)
        # construct_tables! got removed by rails
        # https://github.com/rails/rails/commit/590b045ee2c0906ff162e6658a184afb201865d7
        #
        # construct_tables_for_association! is a method from the polyamorous (ransack) gem
        join_root = join_dependency.send(:join_root)
        join_root.each_children do |parent, child|
          join_dependency.construct_tables_for_association!(parent, child)
        end

        join_association = find_join_association(associations)
        join_association.table
      end

      private

      Associations = ::ActiveRecord::Associations

      def find_join_association(associations)
        current = join_dependency.send(:join_root)

        associations.each do |association|
          name = association._reflection.name
          current = current.children.find { |c| c.reflection.name == name && klass_equal?(association, c) }
          break if current.nil?
        end

        current
      end

      # If association is not polymorphic return true.
      # If association is polymorphic compare the association polymorphic class with the join association base_klass
      def klass_equal?(assoc, join_association)
        return true unless assoc._reflection.polymorphic?

        assoc._polymorphic_klass == join_association.base_klass
      end

      def collect_joins(relation)
        joins = []
        joins += relation.joins_values
        joins += relation.left_outer_joins_values

        _buckets = joins.group_by do |join|
          case join
          when String
            :string_join
          when Hash, Symbol, Array
            :association_join
          when Associations::JoinDependency
            :stashed_join
          when Arel::Nodes::Join
            :join_node
          when BabySqueel::Join
            :association_join
          else
            raise("unknown class: %s" % join.class.name)
          end
        end
      end

      def build(relation, buckets)
        buckets.default = []
        association_joins         = buckets[:association_join]
        stashed_association_joins = buckets[:stashed_join]
        join_nodes                = buckets[:join_node].uniq
        string_joins              = buckets[:string_join].map(&:strip).uniq

        joins = string_joins.map do |join|
          relation.table.create_string_join(Arel.sql(join)) unless join.blank?
        end.compact

        join_list = join_nodes + joins

        alias_tracker = Associations::AliasTracker.create(BabySqueel::ActiveRecord::VersionHelper.at_least_7_2? ? relation.klass.connection.pool : relation.klass.connection, relation.table.name, join_list)
        join_dependency = Associations::JoinDependency.new(relation.klass, relation.table, association_joins, Arel::Nodes::InnerJoin)
        join_dependency.instance_variable_set(:@alias_tracker, alias_tracker)

        join_nodes.each do |join|
          join_dependency.send(:alias_tracker).aliases[join.left.name.downcase] = 1
        end

        join_dependency
      end
    end
  end
end
