class Arel::Nodes::TableAlias
  def on(node = nil, &block)
    table = BabySqueel::Table.new(self)
    table.on(node, &block)
  end
end
