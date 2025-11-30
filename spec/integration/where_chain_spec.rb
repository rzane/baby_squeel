require 'spec_helper'

describe '#where.has' do
  it 'wheres on an attribute' do
    relation = Post.where.has {
      title == 'OJ Simpson'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'accepts nil' do
    relation = Post.where.has { nil }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on associations' do
    relation = Post.joins(:author).where.has {
      author.name == 'Yo Gotti'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres using functions' do
    relation = Post.joins(:author).where.has {
      coalesce(title, author.name) == 'meatloaf'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres using operations' do
    relation = Post.where.has { (id + 1) == 2 }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres using complex conditions' do
    relation = Post.joins(:author).where.has {
      (title =~ 'Simp%').or(author.name == 'meatloaf')
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on deep associations' do
    relation = Post.joins(author: :comments).where.has {
      author.comments.id > 0
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on an aliased association' do
    relation = Post.joins(author: :posts).where.has {
      author.posts.id > 0
    }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end

  it 'wheres on an aliased association with through' do
    relation = Post.joins(:comments, :author_comments).where.has {
      author_comments.id > 0
    }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end

  it 'wheres on polymorphic associations' do
    relation = Picture.joining { imageable.of(Post) }.where.has {
      imageable.of(Post).title =~ 'meatloaf'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on polymorphic associations outer join' do
    relation = Picture.joining { imageable.of(Post).outer }.where.has {
      imageable.of(Post).title =~ 'meatloaf'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres and correctly aliases' do
    relation = Post.joining { author.comments }
                    .where.has { author.comments.id.in [1, 2] }
                    .where.has { author.name == 'Joe' }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on an alias with outer join' do
    relation = Post.joining { author.comments.outer }
                    .where.has { author.comments.id.in [1, 2] }
                    .where.has { author.name == 'Joe' }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres on an alias with a function' do
    relation = Post.joins(author: :posts).where.has {
      coalesce(author.posts.id, 1) > 0
    }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end

  it 'wheres with a subquery' do
    relation = Post.joins(:author).where.has {
      author.id.in Author.selecting { id }.limit(3)
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres with an empty subquery' do
    relation = Post.where.has {
      author_id.in Author.none.select(:id)
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres with an empty subquery and keeps values' do
    other = Author.joins(:posts)
                  .group(:id)
                  .select(:id)
                  .order(:id)
                  .none

    relation = Post.where.has { author_id.in other }
    expect(relation).to match_sql_snapshot
  end

  it 'wheres with a not in subquery' do
    relation = Post.where.has {
      author_id.not_in Author.none.select(:id)
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres using a simple table' do
    simple = BabySqueel[:authors, type_caster: Author.type_caster]

    relation = Post.joins(:author).where.has {
      simple.name == 'Yo Gotti'
    }

    expect(relation).to match_sql_snapshot
  end

  it 'builds an exists query' do
    relation = Post.where.has {
      exists Post.where.has { author_id == 1 }
    }

    expect(relation).to match_sql_snapshot
  end

  it 'builds a not exists query' do
    relation = Post.where.has {
      not_exists Post.where.has { author_id == 1 }
    }

    expect(relation).to match_sql_snapshot
  end

  it 'wheres an association using #==' do
    author = Author.new(id: 42)
    relation = Post.where.has do |post|
      post.author == author
    end

    expect(relation).to match_sql_snapshot
  end

  it 'wheres an association using #!=' do
    author = Author.new(id: 42)
    relation = Post.where.has do |post|
      post.author != author
    end

    expect(relation).to match_sql_snapshot
  end

  it 'handles a hash' do
    bs = Post.where.has { { id: 1 } }
    ar = Post.where(id: 1)

    expect(bs.to_sql).to eq(ar.to_sql)
  end

  it 'handles an empty hash' do
    bs = Post.where.has { {} }
    ar = Post.where({})

    expect(bs.to_sql).to eq(ar.to_sql)
  end
end

describe '#where_values_hash' do
  it 'returns the same hash that Rails normally would' do
    bs = Author.where.has{id == 123}
    ar = Author.where(id: 123)
    expect(bs.where_values_hash).to eq(ar.where_values_hash)
  end
end
