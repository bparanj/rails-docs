# frozen_string_literal: true

require 'bundler/inline'
require 'debug'

gemfile(true) do
  source 'https://rubygems.org'

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem 'rails', github: 'rails/rails'
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
  end
end

class Post < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_find_by_nil
    post = Post.create!(title: 'Test Post')
    result = Post.find_by(nil)
    debugger
    assert_equal post.title, result.title
    assert result.class == Post
    assert_nil result
  end
end
