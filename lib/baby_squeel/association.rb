require 'baby_squeel/relation'

module BabySqueel
  class Association < Relation
    # An Active Record association reflection
    attr_reader :_reflection

    # The class to use for the join conditions of polymorphic assocaitions
    attr_reader :_polymorphic_klass

    def initialize(parent, reflection, polymorphic_klass = nil)
      @parent = parent
      @_reflection = reflection
      @_polymorphic_klass = polymorphic_klass
      super(polymorphic_klass || @_reflection.klass)
    end

    def needs_polyamorous?
      _reflection.polymorphic? || _join == Arel::Nodes::OuterJoin
    end

    # See JoinExpression#add_to_tree.
    def add_to_tree(hash)
      polyamorous = Polyamorous::Join.new(
        _reflection.name,
        _join,
        _polymorphic_klass
      )

      hash[polyamorous] ||= {}
    end

    # See BabySqueel::Table#find_alias.
    def find_alias(association, associations = [])
      @parent.find_alias(association, [self, *associations])
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
      elsif _table.is_a? Arel::Nodes::TableAlias
        raise AssociationAliasingError.new(_reflection.name, _table.right)
      else
        @parent._arel([self, *associations])
      end
    end
  end
end
