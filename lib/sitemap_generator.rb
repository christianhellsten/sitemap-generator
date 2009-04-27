ENV['RAILS_ENV'] ||= "development"  

#require 'rubygems'
#require 'config/environment'

module SitemapGenerator
  module Version #:nodoc:
    Major = 0
    Minor = 1
    Tiny  = 0 
    
    String = [Major, Minor, Tiny].join('.')
  end
end
