# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails"
  gem "sqlite3"
end

require "active_record/railtie"
require "active_storage/engine"
require "tmpdir"

class TestApp < Rails::Application
  config.load_defaults Rails::VERSION::STRING.to_f

  config.root = __dir__
  config.hosts << "example.org"
  config.eager_load = false
  config.session_store :cookie_store, key: "cookie_store_key"
  config.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  config.active_storage.service = :local
  config.active_storage.service_configurations = {
    local: {
      root: Dir.tmpdir,
      service: "Disk"
    }
  }
end

ENV["DATABASE_URL"] = "sqlite3::memory:"

Rails.application.initialize!

require ActiveStorage::Engine.root.join("db/migrate/20170806125915_create_active_storage_tables.rb").to_s

ActiveRecord::Schema.define do
  CreateActiveStorageTables.new.change

  create_table :visuals, force: true
end

class Visual < ActiveRecord::Base
  has_one_attached :file do |attachable|
    attachable.variant :preview, resize_to_fill: [200, 200], preprocessed: true
  end
end

require "minitest/autorun"

class BugTest < Minitest::Test
  def test_attachment
    visual = Visual.create!
    file = File.open(Rails.root.join('.', 'dog.jpeg'))
    visual.file.attach(io: file, filename: "dog.jpeg", content_type: "image/jpeg")

    Visual.with_attached_file.each do |visual|
      visual.file.representation(:preview)
    end
  end
end