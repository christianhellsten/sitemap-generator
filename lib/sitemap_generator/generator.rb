require 'open-uri'

include ActionController::UrlWriter

module SitemapGenerator
  class Generator

    DEFAULT_OPTIONS = {
      :order      => nil, 
      :limit      => Options.limit, 
      :priority   => Options.priority, 
      :change_frequency => Options.change_frequency
    }

    def initialize(filename = "#{RAILS_ROOT}/public/sitemap.xml")
      @filename = filename
      @old_size, @new_size = File.size(@filename) rescue 0
    end

    def find_models
      models = []

      files = Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).delete_if {|c| c =~ /observer\.rb/ } #{|c| c < ActiveRecord::Base== false}

      files.each do |file|
        # Get the class from the filename
        model = file.split('/').last[0..-4].classify.constantize
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
          # Use defaults
          options = DEFAULT_OPTIONS.merge(model.sitemap_options)

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
        options[:order] = "#{order.first} ASC"
      end

      puts "Sitemap #{model} #{options.inspect}"

      # This is where we create the sitemap. 
      # Find and add model instances to the sitemap
      model.all(:order => options[:order], :limit => options[:limit]).each do |o|
        data.add o, options[:priority], options[:change_frequency]
      end
    end

    def generate(&block)

      File.open(@filename, "w") do |file|  
        xml = Builder::XmlMarkup.new(:target => file, :indent => 2)  
        xml.instruct!

        xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do  
          block.call(Sitemap.new(xml))
        end
      end

      @new_size = File.size(@filename)

      ping if ping?

      puts "Sitemap '#{@filename}' generated successfully."
    end

    def ping?
      valid? && changed? && RAILS_ENV == 'production'
    end

    def changed?
      # NOTE Digest would be better, but is not efficient with large sitemaps
      @old_size != @new_size 
    end

    def valid?
      # TODO 1. Sitemap can contain a maximum of 50 000 entries
      # TODO 2. Sitemap should be valid XML
      # TODO 3. Sitemap should be no more than x MB
      
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
