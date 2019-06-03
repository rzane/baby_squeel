shared_examples_for 'a relation' do
  describe '#respond_to?' do
    it 'resolves associations' do
      is_expected.to respond_to(:author)
    end
  end

  describe '#association' do
    it 'builds a table from the associated class' do
      expect(table.association(:author)).to be_a(BabySqueel::Table)
    end

    it 'allows chaining attributes' do
      assoc = table.association :author
      expect(assoc.id).to be_a(Arel::Attributes::Attribute)
    end

    it 'raises an error for non-existant associations' do
      expect {
        table.association :non_existent
      }.to raise_error(
        BabySqueel::AssociationNotFoundError,
        /named 'non_existent'(.+)for Post/
      )
    end
  end

  describe '#method_missing' do
    it 'resolves associations' do
      expect(table.author).to be_a(BabySqueel::Association)
    end

    it 'raises a custom error for things that look like columns' do
      if ENV['COMPAT']
        skip "This isn't supported in Squeel Compatibility mode"
      end
      expect { table.non_existent_column }.to raise_error(BabySqueel::NotFoundError)
    end
  end
end
