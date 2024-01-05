# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # gem 'rails', github: 'rails/rails'
  # This fails
  gem 'rails', '7.1.0.beta1'
  # This works
  # gem 'rails', '7.0.8'
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

class Subscriber
  attr_reader :events

  def initialize
    @events = []
  end

  def start(_name, _id, payload)
    return if payload[:name] == 'SCHEMA'

    # substitution here to strip out the new default return on the main branch
    events << [:start, payload[:sql].sub(/ RETURNING "id"/, '')]
  end

  def finish(_name, _id, payload)
    return if payload[:name] == 'SCHEMA'

    events << [:finish, payload[:sql].sub(/ RETURNING "id"/, '')]
  end

  def publish(*); end

  def publish_event(*); end
end

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    subscriber = Subscriber.new
    ActiveSupport::Notifications.subscribe('sql.active_record', subscriber)

    post = Post.create!

    post.destroy

    create_events = subscriber.events.slice!(0, 6)
    destroy_events = subscriber.events

    expected_create_order = [
      [:start, 'begin transaction'],
      [:finish, 'begin transaction'],
      [:start, 'INSERT INTO "posts" DEFAULT VALUES'],
      [:finish, 'INSERT INTO "posts" DEFAULT VALUES'],
      [:start, 'commit transaction'],
      [:finish, 'commit transaction']
    ]

    expected_destroy_order = [
      [:start, 'begin transaction'],
      [:finish, 'begin transaction'],
      [:start, 'DELETE FROM "posts" WHERE "posts"."id" = ?'],
      [:finish, 'DELETE FROM "posts" WHERE "posts"."id" = ?'],
      [:start, 'commit transaction'],
      [:finish, 'commit transaction']
    ]

    assert_equal(create_events, expected_create_order)
    assert_equal(destroy_events, expected_destroy_order)
  end
end
