# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :articles, force: true do |t|
  end
end

class BugTest < Minitest::Test
  class BugTest < Minitest::Test
    def test_non_existent_record
      assert_raises(ActiveRecord::RecordNotFound) do
        Article.find(1)
      end
    end
  end  
end
