# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "~> 7.1.2"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
  end
end

class Post < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_marshal_61
    ActiveRecord::Marshalling.format_version = 6.1

    post = Post.new(:title => "Test")
    assert post.title_changed?

    marshalled = Marshal.dump(post)

    unmarshalled = Marshal.load(marshalled)
    assert unmarshalled.title_changed?
  end

  def test_marshal_71
    ActiveRecord::Marshalling.format_version = 7.1

    post = Post.new(:title => "Test")
    assert post.title_changed?

    marshalled = Marshal.dump(post)

    unmarshalled = Marshal.load(marshalled)
    assert unmarshalled.title_changed?
  end
end