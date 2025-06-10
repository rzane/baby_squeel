require 'spec_helper'

describe '#averaging' do
  let(:a1) { Author.create! age: 5 }
  let(:a2) { Author.create! age: 5 }

  before do
    [Post, Author].each(&:delete_all)
    Post.create! view_count: 2, author: a1
    Post.create! view_count: 4, author: a1
    Post.create! view_count: 6, author: a2
  end

  it 'averages attributes' do
    expect(Post.averaging { view_count }).to eq(4.0)
  end

  it 'averages expressions' do
    expect(Post.averaging { view_count + 2 }).to eq(6.0)
  end

  it 'averages associations' do
    expect(Post.joins(:author).averaging { author.age }).to eq(5)
  end

  it 'averages with group' do
    expect(Post.group(:author_id).averaging { view_count }).to eq(
      a1.id => 3.0,
      a2.id => 6.0
    )
  end

  it 'averages with a sane alias' do
    queries = track_queries do
      Post.group(:author_id).averaging { view_count }
    end

    expect(queries.last).to produce_sql(
      /AVG\("posts"."view_count"\) AS "?average_posts_view_count/
    )
  end
end
