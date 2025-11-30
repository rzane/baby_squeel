require 'spec_helper'

describe '#grouping' do
  it 'groups on a column' do
    relation = Post.selecting { id.count }.grouping { author_id }

    expect(relation).to match_sql_snapshot
  end

  it 'groups on a calculation' do
    relation = Post.selecting { id.count }.grouping {
      (author_id + 1) + 5
    }

    expect(relation).to match_sql_snapshot
  end

  it 'groups on an association' do
    relation = Post.joins(:author).selecting { id.count }.grouping { author.id }

    expect(relation).to match_sql_snapshot
  end

  it 'groups on an aliased association' do
    relation = Post.joining { author.posts }
                   .selecting { author.posts.id.count }
                   .grouping { author.posts.author_id }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end
end
