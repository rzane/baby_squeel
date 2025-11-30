require 'spec_helper'

describe BabySqueel::ActiveRecord::Base, '#sifter' do
  before do
    Post.sifter(:crap) { |num| id == num }
    Author.sifter(:boogers) { name =~ 'boogies%' }
    Post.sifter :author_comments_id do |num|
      author_comments.id > num
    end
  end

  after do
    Post.singleton_class.send :undef_method, :sift_crap
    Author.singleton_class.send :undef_method, :sift_boogers
    Post.singleton_class.send :undef_method, :sift_author_comments_id
  end

  it 'defines a new method' do
    expect(Post).to respond_to(:sift_crap)
  end

  it 'builds arel' do
    expect(Post.sift_crap(1)).to be_a(Arel::Nodes::Equality)
  end

  it 'allows the use of the sifter' do
    relation = Post.where.has { sift :crap, 5 }

    expect(relation).to match_sql_snapshot
  end

  it 'allows the use of a sifter on an association' do
    relation = Post.joins(:author).where.has {
      author.sift :boogers
    }

    expect(relation).to match_sql_snapshot
  end

  it 'yield the root table to the block when arity is given' do
    relation = Post.joins(:comments, :author_comments).where.has {
      sift :author_comments_id, 1
    }

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end
end
