require 'spec_helper'

describe 'test that plain rails still works' do
  it 'joins and merge' do
    relation = Author.joins(:posts).merge(Post.joins(:comments).merge(Comment.where(body: 'body')))

    expect(relation).to match_sql_snapshot
  end

  it 'left_joins' do
    relation = Post.left_joins(:parent, :author)

    expect(relation).to match_sql_snapshot(variants: ['8.1', '8.2'])
  end

  it 'joins includes' do
    relation = Post.joins(:author).includes(:author).to_sql

    expect(relation).to match_sql_snapshot
  end
end
