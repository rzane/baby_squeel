require 'spec_helper'

describe '#when_having' do
  it 'adds a having clause' do
    relation = Post.selecting { id.count }
                   .grouping { author_id }
                   .when_having { id.count > 5 }

    expect(relation).to match_sql_snapshot
  end

  it 'adds a having clause with a calculation' do
    relation = Post.selecting { id.count }
                   .grouping { (author_id + 5 ) * 3 }
                   .when_having { id.count > 5 }

    expect(relation).to match_sql_snapshot
  end

  it 'adds a having clause with an association' do
    relation = Post.selecting { id.count }
                   .joins(:author)
                   .grouping { author.id }
                   .when_having { author.id.count > 5 }

    expect(relation).to match_sql_snapshot
  end

  it 'adds a having clause with an aliased table' do
    relation = Post.selecting { author.posts.id.count }
                   .joining { author.posts }
                   .grouping { author.posts.id }
                   .when_having { author.posts.id.count > 5 }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end
end
