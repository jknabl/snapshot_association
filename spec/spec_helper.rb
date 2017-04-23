require 'bundler/setup'
require 'active_record'
require 'pry'
require_relative '../lib/snapshot_association'

# obtain a DB connection
ActiveRecord::Base.establish_connection(
  adapter: :sqlite3,
  database: ":memory:",
  timeout: 500
)
ActiveRecord::Base.default_timezone = :utc

# migrate test schema
ActiveRecord::Migrator.migrate('spec/db/migrate')

class Thing < ActiveRecord::Base
  has_many :thing_events
end

class ThingEvent < ActiveRecord::Base
  belongs_to :thing
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    # remove any callbacks we may have added dynamically during a test
    ThingEvent.reset_callbacks(:save)
    ThingEvent.reset_callbacks(:create)
  end
end
