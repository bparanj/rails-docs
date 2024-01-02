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
  end
end

class Article < ActiveRecord::Base
end

# Represents an executable documentation for ActiveRecord::Base#find method for the edge cases.
#
# @example
#   ruby cases/find.rb
class Find < Minitest::Test
  # Documents the input and output of the find method.
  #
  # @param input [Integer, String, Array<Integer>, Array<String>] The input to be passed to the find method.
  # @return [Array] the output type is an array.
  def test_interface
    result = Article.find([])

    assert_equal Array, result.class
  end

  # Tests the behavior of the find method when a non-existent record ID is passed as an argument.
  #
  # @raise [ActiveRecord::RecordNotFound] if the record with the given ID does not exist.
  def test_non_existent_record
    assert_raises(ActiveRecord::RecordNotFound) do
      Article.find(1)
    end
  end

  # Tests the behavior of the find method when nil is passed as an argument.
  #
  # @raise [ActiveRecord::RecordNotFound] if the argument is nil.
  def test_find_with_nil
    assert_raises(ActiveRecord::RecordNotFound) do
      Article.find(nil)
    end
  end

  # Tests the behavior of the find method when no argument is passed.
  #
  # @raise [ActiveRecord::RecordNotFound] if no argument is provided.
  def test_find_with_no_argument
    assert_raises(ActiveRecord::RecordNotFound) do
      Article.find
    end
  end

  # Tests the behavior of the find method when an empty array is passed as an argument.
  #
  # @return [Array] An empty array.
  def test_find_with_empty_array
    result = Article.find([])

    assert_equal 0, result.size
  end

  # Tests the behavior of the find method when a non-existent record ID is passed as an element of an array.
  #
  # @raise [ActiveRecord::RecordNotFound] if the record with the given ID does not exist.
  def test_non_existent_record_in_array
    assert_raises(ActiveRecord::RecordNotFound) do
      Article.find([1])
    end
  end
end
