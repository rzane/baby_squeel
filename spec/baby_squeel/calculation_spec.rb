require 'spec_helper'

RSpec.describe BabySqueel::Calculation do
  let(:table) { Arel::Table.new('posts') }

  describe '#node' do
    it 'reads the attribute' do
      calculation = described_class.new(table[:id])
      expect(calculation.node).to eq(table[:id])
    end
  end

  describe '#to_s' do
    it 'generates a name for attribute' do
      calculation = described_class.new(table[:id])
      expect(calculation.to_s).to eq('posts_id')
    end

    it 'generates a name for expressions' do
      node = table[:id] + table[:view_count]
      calculation = described_class.new(node)
      if ActiveRecord::VERSION::MAJOR > 7 || (ActiveRecord::VERSION::MAJOR == 7 && ActiveRecord::VERSION::MINOR >= 2)
        expect(calculation.to_s).to eq('posts_id_posts_view_count')
      else
        expect(calculation.to_s).to eq('posts_id_view_count')
      end
    end
  end
end
