require 'spec_helper'

describe '#minimizing' do
  let(:a1) { Author.create! age: 1 }
  let(:a2) { Author.create! age: 5 }

  before do
    [Post, Author].each(&:delete_all)
    Post.create! view_count: 2, author: a1
    Post.create! view_count: 6, author: a2
  end

  it 'minimizes attributes' do
    expect(Post.minimizing { view_count }).to eq(2)
  end

  it 'minimizes expressions' do
    expect(Post.minimizing { view_count + 2 }).to eq(4)
  end

  it 'minimizes associations' do
    expect(Post.joins(:author).minimizing { author.age }).to eq(1)
  end

  it 'minimizes with group' do
    expect(Post.group(:author_id).minimizing { view_count }).to eq(
      a1.id => 2,
      a2.id => 6
    )
  end

  it 'minimizes with a sane alias' do
    queries = track_queries do
      Post.group(:author_id).minimizing { view_count }
    end

    if ActiveRecord::VERSION::MAJOR >= 8
      expect(queries.last).to produce_sql(
        /MIN\("posts"."view_count"\) AS "?minimum_struct_arel_attributes_attribute/
      )
    else
      expect(queries.last).to produce_sql(
        /MIN\("posts"."view_count"\) AS "?minimum_posts_view_count/
      )
    end
  end
end
