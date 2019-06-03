module BabySqueel
  class Resolver
    def initialize(table, strategies)
      @table       = table
      @strategies  = strategies
    end

    # Attempt to determine the intent of the method_missing. If this method
    # returns nil, that means one of two things:
    #
    # 1. The argument signature is invalid.
    # 2. The name of the method called is not valid (ex. invalid column name)
    def resolve(name, *args, &block)
      strategy = @strategies.find do |strategy|
        valid?(strategy, name, *args, &block)
      end

      build(strategy, name, *args, &block)
    end

    # Try to resolve the method_missing. If we fail to resolve, there are
    # two outcomes:
    #
    # If any of the configured strategies accept argument signature provided,
    # raise an error. This means we failed to resolve the name. (ex. invalid
    # column name)
    #
    # Otherwise, a nil return valid indicates that argument signature was not
    # valid for any of the configured strategies. This case should be treated
    # as a NoMethodError.
    def resolve!(name, *args, &block)
      if resolution = resolve(name, *args, &block)
        return resolution
      end

      if compatible_arguments?(*args, &block)
        raise NotFoundError.new(@table._scope.model_name, name, @strategies)
      end

      return nil
    end

    # Used to determine if a table can respond_to? a method.
    def resolves?(name)
      @strategies.any? do |strategy|
        valid_name? strategy, name
      end
    end

    private

    def build(strategy, name, *args)
      case strategy
      when :function
        @table.func(name, *args)
      when :association
        @table.association(name)
      when :column, :attribute
        @table[name]
      when :table
        Table.new(Arel::Table.new(name))
      end
    end

    def valid?(strategy, name, *args, &block)
      valid_arguments?(strategy, *args, &block) &&
        valid_name?(strategy, name)
    end

    def valid_name?(strategy, name)
      case strategy
      when :column
        @table._scope.column_names.include?(name.to_s)
      when :association
        !@table._scope.reflect_on_association(name).nil?
      when :function, :attribute, :table
        true
      end
    end

    def valid_arguments?(strategy, *args)
      return false if block_given?

      case strategy
      when :function
        !args.empty?
      when :column, :attribute, :association, :table
        args.empty?
      end
    end

    def compatible_arguments?(*args, &block)
      @strategies.any? do |strategy|
        valid_arguments?(strategy, *args, &block)
      end
    end
  end
end
