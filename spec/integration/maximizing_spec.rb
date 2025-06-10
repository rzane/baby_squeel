require 'spec_helper'

describe '#maximizing' do
  let(:a1) { Author.create! age: 1 }
  let(:a2) { Author.create! age: 5 }

  before do
    [Post, Author].each(&:delete_all)
    Post.create! view_count: 2, author: a1
    Post.create! view_count: 6, author: a2
  end

  it 'maximizes attributes' do
    expect(Post.maximizing { view_count }).to eq(6)
  end

  it 'maximizes expressions' do
    expect(Post.maximizing { view_count + 2 }).to eq(8)
  end

  it 'maximizes associations' do
    expect(Post.joins(:author).maximizing { author.age }).to eq(5)
  end

  it 'maximizes with group' do
    expect(Post.group(:author_id).maximizing { view_count }).to eq(
      a1.id => 2,
      a2.id => 6
    )
  end

  it 'maximizes with a sane alias' do
    queries = track_queries do
      Post.group(:author_id).maximizing { view_count }
    end

    if ActiveRecord::VERSION::MAJOR >= 8
      expect(queries.last).to produce_sql(
        /MAX\("posts"."view_count"\) AS "?maximum_struct_arel_attributes_attribute/
      )
    else
      expect(queries.last).to produce_sql(
        /MAX\("posts"."view_count"\) AS "?maximum_posts_view_count/
      )
    end
  end
end
