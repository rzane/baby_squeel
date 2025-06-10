module BabySqueel
  class Calculation # :nodoc:
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # In Active Record 5, we don't *need* this class to make
    # calculations work. They happily accept arel. However,
    # when grouping with a calculation, there's a really,
    # really weird alias name. It calls #to_s on the Arel.
    #
    # If this were not addressed, it would likely break query
    # caching because the alias would have a unique name every
    # time.
    def to_s
      if node.respond_to?(:map)
        names = node.map do |child|
          if child.kind_of?(String) || child.kind_of?(Symbol)
            child.to_s
          elsif child.respond_to?(:name)
            child.name.to_s
          end
        end
        names.compact.uniq.join('_')
      else
        # fix for https://github.com/rails/rails/commit/fc38ff6e4417295c870f419f7c164ab5a7dbc4a5
        node.to_sql.split('"').map { |v| v.tr('^A-Za-z0-9_', '').presence }.compact.uniq.join('_')
      end
    end
  end
end
