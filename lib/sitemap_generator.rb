module SitemapGenerator
  DOMAIN = nil

  module Version #:nodoc:
    Major = 1
    Minor = 1
    Tiny  = 0 
    
    String = [Major, Minor, Tiny].join('.')
  end
end

# need this for config.threadsafe!
if Rails.env == 'production'
  require File.join(Rails.root, 'config', 'environment')
  require File.join(File.dirname(__FILE__), '/sitemap_generator/active_record')
  require File.join(File.dirname(__FILE__), '/sitemap_generator/generator')
  require File.join(File.dirname(__FILE__), '/sitemap_generator/helpers')
  require File.join(File.dirname(__FILE__), '/sitemap_generator/options')
  require File.join(File.dirname(__FILE__), '/sitemap_generator/sitemap')
end
