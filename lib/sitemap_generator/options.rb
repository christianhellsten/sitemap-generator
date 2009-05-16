module SitemapGenerator
  class Options
    CONFIG_FILE = 'config/sitemap.yml'

    class << self

      def method_missing(name, *args)
        if options.has_key?(name.to_s)
          (class << self; self; end).class_eval do
            define_method(name) do
              @@options[name.to_s]
            end
          end
        else
          raise ArgumentError, "#{name} setting not found in '#{CONFIG_FILE}'"
        end

        send(name, *args)
      end

      protected

      def [](key)
        options[key]
      end

      def options
        @@options ||= YAML::load(File.read(RAILS_ROOT + '/' + CONFIG_FILE))
      end
    end
  end
end
