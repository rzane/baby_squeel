module Factories
  def create_table(name)
    table = Arel::Table.new(name)
    BabySqueel::Table.new(table)
  end

  def create_dsl(klass)
    BabySqueel::DSL.new(klass)
  end

  def create_relation(klass)
    BabySqueel::Relation.new(klass)
  end

  def create_association(klass, association, polymorphic_klass = nil)
    BabySqueel::Association.new(
      create_relation(klass),
      klass.reflect_on_association(association),
      polymorphic_klass
    )
  end
end
