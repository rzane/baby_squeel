#### Issue

Please explain this issue you're encountering to the best of your ability.

#### Reproduction

```ruby
require 'bundler/inline'
require 'minitest/spec'
require 'minitest/autorun'

gemfile true do
  source 'https://rubygems.org'
  gem 'activerecord', '~> 7.1.5' # which Active Record version?
  gem 'sqlite3'
  gem 'baby_squeel', github: 'rzane/baby_squeel'
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  create_table :dogs, force: true do |t|
    t.string :name
  end
end

class Dog < ActiveRecord::Base
end

class BabySqueelTest < Minitest::Spec
  it 'works' do
    scope = Dog.where.has { name == 'Fido' }

    scope.to_sql.must_equal %{
      SELECT "dogs".* FROM "dogs" WHERE "dogs"."name" = 'Fido'
    }.squish
  end
end
```
