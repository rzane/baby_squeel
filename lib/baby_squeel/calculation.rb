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
      case node
      when Arel::Attributes::Attribute
        # Simple attribute case - handle this specifically to avoid the struct.map issue
        "#{node.relation.name}_#{node.name}"
      when Array
        # Handle array of nodes
        names = node.map do |child|
          if child.kind_of?(String) || child.kind_of?(Symbol)
            child.to_s
          elsif child.respond_to?(:name)
            child.name.to_s
          end
        end
        names.compact.uniq.join('_')
      else
        # For complex expressions, try to extract meaningful parts
        # without calling to_sql which requires a database connection
        extract_node_name(node)
      end
    end

    private

    def extract_node_name(node)
      case node
      when Arel::Attributes::Attribute
        "#{node.relation.name}_#{node.name}"
      when Arel::Nodes::Binary
        left_name = extract_node_name(node.left)
        right_name = extract_node_name(node.right) if node.right.respond_to?(:name) || node.right.respond_to?(:relation)
        [left_name, right_name].compact.join('_')
      when Arel::Nodes::Grouping
        extract_node_name(node.expr)
      when Arel::Nodes::Function
        args = node.expressions.map { |expr| extract_node_name(expr) }.compact
        "#{node.name.downcase}_#{args.join('_')}"
      else
        # Fallback to a safe default
        node.class.name.split('::').last.downcase
      end
    end
  end
end
