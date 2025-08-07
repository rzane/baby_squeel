require 'baby_squeel/relation'

module BabySqueel
  class Association < Relation
    # An Active Record association reflection
    attr_reader :_reflection

    # Specifies the model that the polymorphic
    # association should join with
    attr_accessor :_polymorphic_klass

    def initialize(parent, reflection)
      @parent = parent
      @_reflection = reflection

      # In the case of a polymorphic reflection these
      # attributes will be set after calling #of
      unless @_reflection.polymorphic?
        super @_reflection.klass
      end
    end

    def ==(other)
      Nodes.wrap build_where_clause(other).ast
    end

    def !=(other)
      Nodes.wrap build_where_clause(other).invert.ast
    end

    def of(klass)
      unless _reflection.polymorphic?
        raise PolymorphicSpecificationError.new(_reflection.name, klass)
      end

      clone.of! klass
    end

    def of!(klass)
      self._scope = klass
      self._table = klass.arel_table
      self._polymorphic_klass = klass
      self
    end

    def needs_polyamorous?
      _join == Arel::Nodes::OuterJoin || _reflection.polymorphic?
    end

    # See Join#add_to_tree.
    def add_to_tree(hash)
      polyamorous = Polyamorous::Join.new(
        _reflection.name,
        _join,
        _polymorphic_klass
      )

      hash[polyamorous] ||= {}
    end

    # See BabySqueel::Table#find_alias.
    def find_alias(associations = [])
      @parent.find_alias([self, *associations])
    end

    # Intelligently constructs Arel nodes. There are three outcomes:
    #
    # 1. The user explicitly constructed their join using #on.
    #    See BabySqueel::Table#_arel.
    #
    #        Post.joining { author.on(author_id == author.id) }
    #
    # 2. The user aliased an implicitly joined association. ActiveRecord's
    #    join dependency gives us no way of handling this, so we have to
    #    throw an error.
    #
    #        Post.joining { author.as('some_alias') }
    #
    # 3. The user implicitly joined this association, so we pass this
    #    association up the tree until it hits the top-level BabySqueel::Table.
    #    Once it gets there, Arel join nodes will be constructed.
    #
    #        Post.joining { author }
    #
    def _arel(associations = [])
      if _on
        super
      elsif alias?
        raise AssociationAliasingError.new(_reflection.name, _table.right)
      elsif _reflection.polymorphic? && _polymorphic_klass.nil?
        raise PolymorphicNotSpecifiedError.new(_reflection.name)
      else
        @parent._arel([self, *associations])
      end
    end

    private

    def build_where_clause(other)
      if valid_where_clause?(other)
        relation = @parent._scope.all
        relation.send(:build_where_clause, { _reflection.name => other }, [])
      else
        raise AssociationComparisonError.new(_reflection.name, other)
      end
    end

    def valid_where_clause?(other)
      if other.respond_to? :all?
        other.all? { |o| valid_where_clause? o }
      else
        other.nil? || other.respond_to?(:model_name)
      end
    end
  end
end
