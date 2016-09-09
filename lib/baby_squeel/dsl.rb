require 'baby_squeel/nodes'
require 'baby_squeel/relation'
require 'baby_squeel/association'

module BabySqueel
  class DSL < Relation
    class << self
      # Evaluates a block and unwraps the nodes
      def evaluate(scope, &block)
        Nodes.unwrap evaluate!(scope, &block)
      end

      # Evaluates a block in the context of a DSL instance
      def evaluate!(scope, &block)
        new(scope).evaluate(&block)
      end

      # Evaluates a block in the context of a new DSL instance
      # and passes all arguments to the block.
      def evaluate_sifter(scope, *args, &block)
        evaluate scope do |root|
          root.instance_exec(*args, &block)
        end
      end
    end

    # Create a SQL function. See Arel::Nodes::NamedFunction.
    #
    # ==== Arguments
    #
    # * +name+ - The name of a SQL function (ex. coalesce).
    # * +args+ - The arguments to be passed to the SQL function.
    #
    # ==== Example
    #     Post.select { func('coalesce', id, 1) }
    #     #=> SELECT COALESCE("posts"."id", 1) FROM "posts"
    #
    def func(name, *args)
      Nodes.wrap Arel::Nodes::NamedFunction.new(name.to_s, args)
    end

    # Generate an EXISTS subselect from an ActiveRecord::Relation
    #
    # ==== Arguments
    #
    # * +relation+ - An ActiveRecord::Relation
    #
    # ==== Example
    #     Post.where.has { exists Post.where(id: 1) }
    #
    def exists(relation)
      func 'EXISTS', sql(relation.to_sql)
    end

    # Generate a NOT EXISTS subselect from an ActiveRecord::Relation
    #
    # ==== Arguments
    #
    # * +relation+ - An ActiveRecord::Relation
    #
    # ==== Example
    #     Post.where.has { not_exists Post.where(id: 1) }
    #
    def not_exists(rel)
      func 'NOT EXISTS', sql(rel.to_sql)
    end

    # See Arel::sql
    def sql(value)
      Nodes.wrap ::Arel.sql(value)
    end

    # Quotes a string and marks it as SQL
    def quoted(value)
      sql _scope.connection.quote(value)
    end

    # Evaluates a DSL block. If arity is given, this method
    # `yield` itself, rather than `instance_eval`.
    def evaluate(&block)
      if block.arity.zero?
        instance_eval(&block)
      else
        yield(self)
      end
    end

    private

    # @override BabySqueel::Relation#method_missing
    def method_missing(name, *args, &block)
      return super if block_given?

      if resolution = resolve(name, *args)
        resolution
      elsif !args.empty?
        func(name, args)
      else
        super
      end
    end
  end
end
