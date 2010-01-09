module SitemapGenerator
  class Options
    CONFIG_FILE = File.join(RAILS_ROOT, 'config/sitemap.yml')
    XML_STYLESHEET = File.join(RAILS_ROOT, 'public/sitemap.xsl')

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
          @@options ||= load_options
        end
        
        def load_options
          yaml = YAML::load(File.read(CONFIG_FILE))
          raise "Looks like your configuration file '#{CONFIG_FILE}' is empty" if !yaml
          yaml
        rescue Errno::ENOENT => e
          raise "Config file '#{CONFIG_FILE}' not found #{e}"
        end
    end
  end
end
