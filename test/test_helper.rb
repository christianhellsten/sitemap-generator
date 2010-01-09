require 'rubygems'
require 'matchy'
require 'rr'
require 'shoulda'
require 'fakeweb'

FakeWeb.allow_net_connect = false

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

# Load the Rails environment
ENV['RAILS_ENV'] = 'test'
 
RAILS_ROOT = File.dirname(__FILE__) + '/rails_app'

require "#{RAILS_ROOT}/config/environment.rb"

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")

