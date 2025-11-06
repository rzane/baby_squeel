require 'spec_helper'

describe '#selecting' do
  it 'selects using arel' do
    relation = Post.selecting { [id, title] }
    expect(relation).to match_sql_snapshot
  end

  it 'selects associations' do
    relation = Post.joins(:author).selecting {
      [id, author.id]
    }

    expect(relation).to match_sql_snapshot
  end

  it 'selects aggregates' do
    relation = Post.selecting { id.count }

    expect(relation).to match_sql_snapshot
  end

  it 'selects using functions' do
    relation = Post.joins(:author).selecting {
      coalesce(id, author.id)
    }

    expect(relation).to match_sql_snapshot
  end

  it 'selects using operations' do
    relation = Post.joins(:author).selecting {
      author.id - id
    }

    expect(relation).to match_sql_snapshot
  end

  it 'selects on an aliased table' do
    relation = Post.joins(author: :posts).selecting {
      author.posts.id
    }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end
end
