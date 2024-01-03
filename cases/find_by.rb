require 'minitest/autorun'
require 'active_record'
require 'debug'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
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
# In `ActiveRecord find_by(arg, *args)`, the input parameters are as follows:

# `arg`:   A hash where keys are the names of the model's attributes and values are 
#          the criteria to match records. For instance, `{name: 'John'}`. It can also be
#          a string with a SQL snippet and placeholders for the values. Example
# 				usage: `Post.find_by "published_at < ?", 2.weeks.ago`.
#  uses the `arg` parameter of the ActiveRecord `find_by` method. 
# In this case, `arg` is a string with a SQL snippet and a placeholder for the date,
# representing more complex query conditions. This is followed by the actual value (`2.weeks.ago`)
# filling the placeholder, which is part of the `*args` (splat arguments).
# This method retrieves the first `Post` record with a `published_at` date 
# earlier than two weeks ago.
# `*args`: An optional splat operator allowing for additional arguments. 
# 				 It's used for more complex queries like SQL snippets with placeholders, 
#					 e.g., `find_by("published_at < ?", Time.current)`.

# `find_by` returns the first record matching the criteria or `nil` if no record matches. 

# `Post.find_by name: 'Spartacus', rating: 4` is using the `arg` parameter in 
# ActiveRecord's `find_by` method. In this case, `arg` is a hash with two key-value pairs: 
# `name: 'Spartacus'` and `rating: 4`. 
# The method will search for the first `Post` record where the `name` is 'Spartacus' 
# and the `rating` is 4.

# Represents an executable documentation for ActiveRecord::Base#find_by method for the edge cases.
#
# @example
#   ruby cases/find_by.rb
class FindBy < Minitest::Test
  # Documents the input and output of the find method.
  #
	# Finds the first record matching the specified conditions.
	# @param arg [Hash] A hash of conditions to match, where keys are attribute names 
	#   and values are the expected values. For example: `{name: 'John'}`.
	# @param args [Array] Additional arguments allowing for more complex queries, 
	#   such as SQL conditions with placeholders. Example usage: `find_by("published_at < ?", Time.current)`.
	# @return [ActiveRecord::Base, nil] The first record that matches the criteria, or `nil` if no record matches.

	def setup
		Article.create!(title: 'First Article', published_at: Time.now - 5.days, rating: 5)
	end

	def teardown
		Article.destroy_all
	end

	def test_interface
		result = Article.find_by("published_at < ?", Time.current)

		assert_equal Article, result.class
	end

	def test_find_by_single_field
    article = Article.find_by(title: 'First Article')

    assert_equal 'First Article', article.title
  end

	def test_find_by_multiple_fields
		article = Article.find_by(title: 'First Article', rating: 5)

    assert_equal 'First Article', article.title
  end

	def test_find_by_conditions
    article = Article.find_by("published_at < ?", Time.now - 4.days)
    assert_equal 'First Article', article.title
  end

	# If no record is found for a given condition, it returns nil
	def test_non_existent_record
		result = Article.find_by(title: 'Nonexistent')

		assert_nil result
	end

	# Returns a record if no matching conditions are given
	def test_find_by_with_nil
		Article.create!
		result = Article.find_by(nil)
		
		refute_nil result
	end

	def test_find_by_nil_field
		result = Article.find_by(title: nil)
    assert_nil result
  end

	# You must provide at least one argument to `find_by`. This is the first argument called arg.
	# ArgumentError: wrong number of arguments (given 0, expected 1+)
	def test_find_with_no_argument
		assert_raises(ArgumentError) do
			Article.find_by
		end
	end

	# Empty string to the first requirement argument retuns a record
	def test_find_by_with_empty_string_for_the_required_parameter
		result = Article.find_by('')
		
		refute_nil result
	end
end
