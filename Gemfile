source 'https://rubygems.org'

# Specify your gem's dependencies in baby_squeel.gemspec
gemspec

case ENV.fetch('AR', 'latest')
when 'latest'
  gem 'activerecord'
when 'master'
  gem 'activerecord', github: 'rails/rails'
else
  gem 'activerecord', ENV['AR']
end

gem 'sqlite3', '~> 2.1'

case ENV.fetch('RANSACK', 'latest')
when 'latest'
  gem 'ransack', require: false
when 'master'
  gem 'ransack', github: 'activerecord-hackery/ransack', require: false
else
  ENV['RANSACK'].split('#').tap do |repo, branch|
    opts = {git: repo, require: false}
    opts[:branch] = branch if branch
    gem 'ransack', opts
  end
end

gem 'bump'

group :test do
  gem 'pry'
  gem 'simplecov'
  gem 'byebug'
end
