require 'spec_helper'

describe '#summing' do
  let(:a1) { Author.create! age: 12 }
  let(:a2) { Author.create! age: 23 }

  before do
    [Post, Author].each(&:delete_all)
    Post.create! view_count: 1, author: a1
    Post.create! view_count: 2, author: a2
  end

  it 'sums attributes' do
    expect(Post.summing { view_count }).to eq(3)
  end

  it 'sums expressions' do
    expect(Post.summing { view_count + 1 }).to eq(5)
  end

  it 'sums associations' do
    expect(Post.joins(:author).summing { author.age }).to eq(35)
  end

  it 'sums with group' do
    expect(Post.group(:author_id).summing { view_count }).to eq(
      a1.id => 1,
      a2.id => 2
    )
  end

  it 'sums with a sane alias' do
    queries = track_queries do
      Post.group(:author_id).summing { view_count }
    end

    expect(queries.last).to produce_sql(
      /SUM\("posts"."view_count"\) AS "?sum_posts_view_count/
    )
  end
end
