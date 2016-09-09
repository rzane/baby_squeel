require 'spec_helper'
require 'baby_squeel/relation'
require 'shared_examples/table'
require 'shared_examples/relation'

describe BabySqueel::Relation do
  subject(:table) { create_relation Post }
  let(:polymorph) { create_relation Picture }

  include_examples 'a table'
  include_examples 'a relation'

  describe '#method_missing' do
    it 'raises a NoMethodError when the wrong number of args are given' do
      expect { table.author(1) }.to raise_error(NoMethodError)
    end

    it 'resolves polymorphic associations' do
      expect(polymorph.imageable(Post)).to be_a(BabySqueel::Association)
    end

    it 'throws an error for a polymorphic association without one argument' do
      expect { polymorph.imageable }.to raise_error(BabySqueel::PolymorphicNotSpecifiedError)
    end
  end
end
