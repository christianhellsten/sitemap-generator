module SitemapGenerator
  DOMAIN = nil

  module Version #:nodoc:
    Major = 1
    Minor = 1
    Tiny  = 0 
    
    String = [Major, Minor, Tiny].join('.')
  end
end

require File.join(RAILS_ROOT, 'config', 'environment')
require File.join(File.dirname(__FILE__), '/sitemap_generator/active_record')
require File.join(File.dirname(__FILE__), '/sitemap_generator/generator')
require File.join(File.dirname(__FILE__), '/sitemap_generator/helpers')
require File.join(File.dirname(__FILE__), '/sitemap_generator/options')
require File.join(File.dirname(__FILE__), '/sitemap_generator/sitemap')
