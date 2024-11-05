module BabySqueel
  module Nodes
    # This proxy class allows us to quack like any arel object. When a
    # method missing is hit, we'll instantiate a new proxy object.
    class Proxy < BasicObject
      # Resolve constants the normal way
      def self.const_missing(name)
        ::Object.const_get(name)
      end

      attr_reader :_arel

      def initialize(arel)
        @_arel = Nodes.unwrap(arel)
      end

      def inspect
        "BabySqueel{#{super}}"
      end

      def respond_to?(meth, include_private = false)
        meth.to_s == '_arel' || _arel.respond_to?(meth, include_private)
      end

      private

      def method_missing(meth, *args, &block)
        if _arel.respond_to?(meth)
          Nodes.wrap _arel.send(meth, *Nodes.unwrap(args), &block)
        else
          super
        end
      end
    end
  end
end
