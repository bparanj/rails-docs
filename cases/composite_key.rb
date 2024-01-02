# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem 'rails', github: 'rails/rails'
  gem 'sqlite3'
  gem 'debug', platforms: %i[mri windows]
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  # How to define composite keys in Rails 7:
  # https://edgeguides.rubyonrails.org/active_record_composite_primary_keys.html
  create_table :products, primary_key: %i[store_id sku] do |t|
    t.integer :store_id
    t.string :sku
    t.text :description
  end
end

class Product < ActiveRecord::Base
end

# CompositeKey class is used for documenting how the find method expects an array to find a single item.
class CompositeKey < Minitest::Test
  # If your table uses a composite primary key, you'll need to pass find an array to find a single item. For instance,
  def test_find_with_composite_keys
    Product.create!(store_id: 1, sku: '2', description: 'document')
    record = Product.find([1, 2])

    assert_equal 1, record.store_id
    assert_equal '2', record.sku
  end

  # https://guides.rubyonrails.org/active_record_querying.html#dynamic-finders
  # This will throw an exception ArgumentError: Expected corresponding value for [\"store_id\", \"sku\"] to be an Array
  def test_find_with_composite_keys_raises_exception
    Product.create!(store_id: 2, sku: '3', description: 'exception')
    # Message: <"undefined method `first' for an instance of Integer">
    assert_raises(NoMethodError) do
      Product.find(2, 3)
    end
  end
end
