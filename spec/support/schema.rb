ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :authors, force: true do |t|
    t.string :name
    t.boolean :ugly
    t.timestamps null: false
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.belongs_to :author
    t.datetime :published_at
    t.timestamps null: false
  end

  create_table :comments, force: true do |t|
    t.string :body
    t.belongs_to :post
    t.belongs_to :author
    t.timestamps null: false
  end

  create_table :pictures, force: true do |t|
    t.belongs_to :comment
    t.references :imageable, polymorphic: true
    t.timestamps null: false
  end
end
