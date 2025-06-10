require 'spec_helper'

describe '#counting' do
  let(:a1) { Author.create! }
  let(:a2) { Author.create! }

  before do
    [Post, Author].each(&:delete_all)
    Post.create! title: 'Foo', author: a1
    Post.create! title: 'Foo'
    Post.create! title: 'Bar', author: a2
  end

  it 'counts' do
    expect(Post.counting { title }).to eq(3)
  end

  it 'counts distinct' do
    expect(Post.distinct.counting { title }).to eq(2)
  end

  it 'counts association' do
    expect(Post.joins(:author).counting { author.id }).to eq(2)
  end

  it 'counts with limit' do
    expect(Post.limit(1).counting { id }).to eq(1)
  end

  it 'counts with group' do
    expect(Post.group(:author_id).counting { id }).to eq(
      a1.id => 1,
      a2.id => 1,
      nil => 1
    )
  end

  it 'counts with a sane alias' do
    queries = track_queries do
      Post.group(:author_id).counting { id }
    end

    if ActiveRecord::VERSION::MAJOR >= 8
      expect(queries.last).to produce_sql(
        /COUNT\("posts"."id"\) AS "?count_struct_arel_attributes_attribute/
      )
    else
      expect(queries.last).to produce_sql(
        /COUNT\("posts"."id"\) AS "?count_posts_id/
      )
    end
  end
end
