module SitemapGenerator
  module ActiveRecord

    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods

        class_inheritable_accessor :sitemap_options
      end
    end

    module ClassMethods
      def sitemap(options = {}, &block)

        # Use a custom generator if given a block
        options[:generator] = block if block_given?

        self.sitemap_options = options
      end
    end

    module InstanceMethods

    end

  end
end
