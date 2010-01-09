require 'open-uri'
require 'find'

include ActionController::UrlWriter

module SitemapGenerator
  class Generator
    def initialize(filename = "#{RAILS_ROOT}/public/sitemap.xml")
      @filename = filename
      @old_size, @new_size = File.size(@filename) rescue 0
    end

    def find_models
      models = []
      model_path = File.join(RAILS_ROOT, 'app', 'models', '/')
      
      # Find all Ruby files
      Dir.glob(File.join(model_path, '**', '*.rb')) do |file|
        next if file =~ /observer.rb/
        # Path should be relative to RAILS_ROOT 
        file.gsub!(model_path, '')
        # Get the class from the filename
        model = file.split('/').map{ |f| f.gsub('.rb', '').classify }.join('::').constantize
        # Skip classes that don't have any sitemap options
        next if !model.methods.include?('sitemap_options') || model.sitemap_options == nil

        models << model
      end

      puts "Sitemap WARNING!! No models found. Have you included a call to the sitemap in your ActiveRecord models?" if models.empty?

      models
    end

    def find_models_and_generate
      # TODO rename data to sitemap
      self.generate do |data|
        self.find_models.each do |model|
          # Default options
          options = {
            :limit      => Options.limit, 
            :priority   => Options.priority, 
            :change_frequency => Options.change_frequency
          }
          options = options.merge(model.sitemap_options)

          # A user defined block that handles sitemap generation
          custom_generator = options[:generator]

          if custom_generator
            custom_generator.call(data.xml)
          else
            auto_generate(model, data, options)
          end

        end
      end
    end

    def auto_generate(model, data, options)
      model_columns = model.columns.map(&:name)

      # Find a column for ordering
      if options[:order] == nil
        order = ['updated_at', 'updated_on', 'created_at', 'created_on'].delete_if { |x| !model_columns.include?(x) }
        options[:order] = "#{order.first} ASC" if !order.blank?
      end

      puts "Sitemap options for '#{model}': #{options.inspect}"

      find_options = {}
      find_options[:order] = options[:order] if options.has_key?(:order)
      find_options[:limit] = options[:limit] if options.has_key?(:limit)

      # This is where we create the sitemap. 
      # Find and add model instances to the sitemap
      # TODO paginate if we have millions of rows
      model.all(find_options).each do |o|
        data.add o, options[:priority], options[:change_frequency]
      end
    end

    def generate(&block)

      File.open(@filename, "w") do |file|  
        xml = Builder::XmlMarkup.new(:target => file, :indent => 2)  
        xml.instruct! 'xml-stylesheet', {:href=>'sitemap.xsl', :type=>'text/xsl'}

        xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation" => "http://www.google.com/schemas/sitemap/0.84 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" do  
          block.call(Sitemap.new(xml))
        end
      end

      @new_size = File.size(@filename)

      ping #if ping?

      puts "Sitemap '#{@filename}' generated successfully."
    end

    def ping?
      valid? && changed? #&& RAILS_ENV == 'production'
    end

    def changed?
      # NOTE Digest would be better, but is not efficient with large sitemaps
      @old_size != @new_size 
    end

    def valid?
      # TODO 1. Sitemap can contain a maximum of 50 000 entries
      # TODO 2. Sitemap should be valid XML
      # TODO 3. Sitemap should be no more than 10 MB
      # TODO 4. Sitemap should contain no more than 1000 files
      
      true
    end

    def ping
      # Ping sites http://en.wikipedia.org/wiki/Sitemaps
      # TODO support other names than sitemap.xml?

      [ "http://www.google.com/webmasters/tools/ping?sitemap=http://#{Options.domain}/sitemap.xml",
        "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=http://#{Options.domain}/sitemap.xml",
        "http://submissions.ask.com/ping?sitemap=http://#{Options.domain}/sitemap.xml",
        "http://webmaster.live.com/ping.aspx?siteMap=http://#{Options.domain}/sitemap.xml" ].each do |url|
        open(url) do |f|
          if f.status[0] == "200"
            puts "Sitemap successfully submitted to #{url}"      
          else
            puts "Failed to submit sitemap to #{url}"
          end
        end
      end
    end
      
    class << self
      def run
        Generator.new.find_models_and_generate
      end

      def generate(&block)
        Generator.new.generate(&block)
      end
    end
    
  end
end
