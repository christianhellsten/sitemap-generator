RAILS_GEM_VERSION = '>= 2.3.2' unless defined? RAILS_GEM_VERSION
 
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.action_controller.session = {
    :key => 'camel_toe_session',
    :secret => 'bc825b3c6d62183601b6f8aa8bcb83dc'
  }
end
 
