module BabySqueel
  class NotFoundError < StandardError # :nodoc:
    def initialize(model_name, name)
      super "There is no column or association named '#{name}' for #{model_name}."
    end
  end

  class AssociationNotFoundError < StandardError  # :nodoc:
    def initialize(model_name, name)
      super "Association named '#{name}' was not found for #{model_name}."
    end
  end

  class AssociationAliasingError < StandardError  # :nodoc:
    MESSAGE =
      "Attempted to alias '%{association}' as '%{alias_name}', but the " \
      "association was implicitly joined. Either join the association " \
      "with `on` or remove the alias. For example:" \
      "\n\n  Post.joining { author }" \
      "\n  Post.joining { author.on(author_id == author.id) }\n\n"

    def initialize(association, alias_name)
      super format(MESSAGE, association: association, alias_name: alias_name)
    end
  end

  class PolymorphicNotSpecifiedError < StandardError # :nodoc:
    MESSAGE =
      "'%{association}' is a polymorphic association, therefore " \
      "you provide a class when joining the association. For example:" \
      "\n\n  %{association}(SomeModel)\n\n"

    def initialize(association)
      super format(MESSAGE, association: association)
    end
  end
end
