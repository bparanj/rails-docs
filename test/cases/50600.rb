# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

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
  Rails.logger = config.logger

  config.active_storage.service = :local
  config.active_storage.service_configurations = {
    local: {
      root: Dir.tmpdir,
      service: "Disk"
    }
  }

  routes.draw do
    mount ActiveStorage::Engine => "/rails/active_storage"
  end
end


ENV["DATABASE_URL"] = "sqlite3::memory:"

Rails.application.initialize!

require ActiveStorage::Engine.root.join("db/migrate/20170806125915_create_active_storage_tables.rb").to_s

ActiveRecord::Schema.define do
  CreateActiveStorageTables.new.change

  create_table :users, force: true
end

class User < ActiveRecord::Base
  has_one_attached :profile
end

require "minitest/autorun"

class DiskControllerTest < Minitest::Test

  def test_directly_uploading_blob_with_different_but_equivalent_content_type
    data = "Something else entirely!"
    user = User.create!
    user.profile.attach(
      io: StringIO.new(data), 
      filename: 'test.txt', 
      content_type: 'application/x-gzip'
    )
  
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: 'test.txt',
      byte_size: data.size,
      checksum: Digest::MD5.base64digest(data),
      content_type: 'application/x-gzip'
    )
  
    Rails.application.routes.default_url_options[:host] = 'localhost'
    put blob.service_url_for_direct_upload, params: { data: data }, headers: { "Content-Type" => "application/x-gzip" }
    assert_response :no_content
  end

  private

  def put(url, params: {}, headers: {})
    session = Rack::Test::Session.new(Rails.application)
    session.put(url, params, headers)
    @last_response = session.last_response
  end

  def last_response
    @last_response
  end

  def assert_response(type)
    response = last_response
    assert response.send("#{type}?"), "Expected response to be #{type}, but was #{response.status}"
  end

  def rails_blob_url(blob, disposition: :attachment)
    Rails.application.routes.default_url_options[:host] = 'localhost'
    Rails.application.routes.url_helpers.rails_blob_url(blob, disposition: disposition)
  end
end
