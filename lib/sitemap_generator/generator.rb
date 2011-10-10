require 'open-uri'
require 'find'
require 'generator'

include Rails.application.routes.url_helpers

module SitemapGenerator
  class Generator
    def initialize(filename = Rails.root + "/public/sitemap.xml")
      @filename = filename
      @old_size, @new_size = File.size(@filename) rescue 0
    end

    def find_models
      models = []

      app_model_path = File.join(Rails.root , 'app', 'models', '/')
      vendor_model_path = File.join(Rails.root , 'vendor', 'plugins', '*', 'app', 'models', '/')

      files = []
      [app_model_path, vendor_model_path].each do |path|
        files += Dir.glob(File.join(path, '**', '*.rb'))
      end

      # Find all Ruby files
      files.each do |file|
        next if file =~ /observer.rb/
        begin
          # Remove path
          f = file.gsub(%r{.*/app/models/}, '')
          # Get the class from the filename
          model = f.split('/').map{ |f| f.gsub('.rb', '').camelize }.join('::').constantize
          # Skip classes that don't have any sitemap options
          next if !model.methods.include?('sitemap_options') || model.sitemap_options == nil

          models << model
        rescue Exception => e
          p "Error processing model #{file}: #{e}"
        end
      end

      p "Sitemap WARNING!! No models found. Have you included a call to the sitemap in your ActiveRecord models?" if models.empty?

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

      p "Sitemap options for '#{model}': #{options.inspect}"

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

      if ping?
        ping
      elsif Options.ping == false
        p "NOTE: pinging of search engines is disabled."
      end

      p "Sitemap '#{@filename}' generated successfully."
      p "NOTE: sitemap has not changed." if !changed?
    end

    def ping?
      return false if !Options.ping # || Rails.env != 'production'
      valid? && changed? 
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

      sitemap = "http://#{Options.domain}/sitemap.xml"

      [ "http://www.google.com/webmasters/tools/ping?sitemap=#{sitemap}",
        "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=#{sitemap}",
        "http://submissions.ask.com/ping?sitemap=#{sitemap}",
        "http://www.bing.com/webmaster/ping.aspx?siteMap=#{sitemap}" ].each do |url|
        open(url) do |f|
          if f.status[0] == "200"
            p "Sitemap successfully submitted to #{url}"      
          else
            p "Failed to submit sitemap to #{url}"
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
