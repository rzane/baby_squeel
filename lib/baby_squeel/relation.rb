require 'baby_squeel/table'

module BabySqueel
  class Relation < Table
    attr_accessor :_scope

    def initialize(scope)
      super(scope.arel_table)
      @_scope = scope
    end

    # Constructs a new BabySqueel::Association. Raises
    # an exception if the association is not found.
    def association(name)
      if reflection = _scope.reflect_on_association(name)
        Association.new(self, reflection)
      else
        not_found_error! name, type: AssociationNotFoundError
      end
    end

    # Invokes a sifter defined on the model
    #
    # ==== Examples
    #     Post.where.has { sift(:name_contains, 'joe') }
    #
    def sift(sifter_name, *args)
      Nodes.wrap _scope.public_send("sift_#{sifter_name}", *args)
    end

    private

    # @override BabySqueel::Table#not_found_error!
    def not_found_error!(name, type: NotFoundError)
      raise type.new(_scope.model_name, name)
    end

    def resolve(name, *args)
      if _scope.column_names.include?(name.to_s)
        self[name]
      else
        resolve_association(name, *args)
      end
    end

    def resolve_association(name, *args)
      reflection = _scope.reflect_on_association(name)

      if reflection && reflection.polymorphic?
        raise PolymorphicNotSpecifiedError.new(reflection.name) if args.empty?
        Association.new(self, reflection, args.first) if args.length == 1
      elsif reflection && args.empty?
        Association.new(self, reflection)
      elsif args.empty?
        not_found_error!(name)
      end
    end

    # @override BabySqueel::Table#method_missing
    def method_missing(name, *args)
      return super if block_given?
      resolve(name, *args) || super
    end
  end
end
