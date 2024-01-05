# frozen_string_literal: true

require 'bundler/inline'

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
  create_table :articles, force: true do |t|
    t.string :title
    t.integer :rating
  
    t.datetime :published_at  
  end
end

class Article < ActiveRecord::Base
end

# 
# Input
# 
# In `ActiveRecord find_sole_by(arg, *args)`, the input parameters are:
#
# - `arg`: Typically a hash specifying the attributes and their values to match in a record. 
#          For example, `{name: 'John', status: 'active'}`.
# - `*args`: A splat operator allowing additional arguments, often used for more complex queries 
#            with SQL conditions and placeholders. 
#            For example, `find_sole_by("created_at > ?", Date.yesterday)`.

# The `find_sole_by` method returns the only record matching the criteria or 
# raises an error if multiple records match or no record matches.

class FindSoleBy < Minitest::Test
  def setup
		Article.create!(title: 'First Article', published_at: Time.now - 5.days, rating: 5)
	end

  def teardown
		Article.destroy_all
	end

  # Documents the input and output of the method.
  #
  # @param input [Integer, String, Array<Integer>, Array<String>] The input to be passed to the find method.
  # @return ActiveRecord the output type is ActiveRecord object.
  def test_interface
    result = Article.find_sole_by(["rating = ?", 5])

    assert_equal Article, result.class
  end

  # Tests the behavior of the method when a non-existent record ID is passed as an argument.
  #
  # @raise [ActiveRecord::RecordNotFound] if the record with the given ID does not exist.
  def test_non_existent_record
    assert_raises(ActiveRecord::RecordNotFound) do
      Article.find_sole_by(["rating = ?", 1])
    end
  end

  # Tests the behavior of the method when nil is passed as an argument.
  #
  # @return ActiveRecord object if the argument is nil.
  # Generated SQL: SELECT "articles".* FROM "articles" ORDER BY "articles"."id" ASC LIMIT ?  [["LIMIT", 2]]
  def test_find_with_nil
    result = Article.find_sole_by(nil)

    assert_equal 'First Article', result.title
  end

  # Tests the behavior of the method when no argument is passed.
  # 
  # The first argument is required. 
  # The second argument is optional.
  # 
  # @raise ArgumentError Message: <"wrong number of arguments (given 0, expected 1+)"> if no argument is provided.
  def test_find_with_no_argument
    assert_raises(ArgumentError) do
      Article.find_sole_by
    end
  end

  # Tests the behavior of the method when an empty array is passed as an argument.
  #
  # @return [Array] An empty array.
  def test_find_with_empty_array
    result = Article.find_sole_by([])

    assert_equal 'First Article', result.title
  end

  # Tests the behavior of the method when there are multiple records that match the search criteria.
  #
  # @raise [ActiveRecord::SoleRecordExceeded] if multiple records match the search criteria.
  def test_multiple_records_case
    Article.create!(title: 'First Article', published_at: Time.now - 5.days, rating: 5)

    assert_raises(ActiveRecord::SoleRecordExceeded) do
      Article.find_sole_by(["rating = ?", 5])
    end
  end
end
