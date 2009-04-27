require 'open-uri'

include ActionController::UrlWriter

module SitemapGenerator
  class Generator
    def initialize(host, filename = "#{RAILS_ROOT}/public/sitemap.xml")
      @host = host
      @filename = filename
      @old_size, @new_size = File.size(@filename) rescue 0
    end

    def generate(&block)
      default_url_options[:host] = @host

      File.open(@filename, "w") do |file|  
        xml = Builder::XmlMarkup.new(:target => file, :indent => 2)  
        xml.instruct!

        xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do  
          block.call(@host, Sitemap.new(@host, xml))
        end
      end

      @new_size = File.size(@filename)

      ping(host) if ping?

      p "Sitemap '#{@filename}' generated successfully."
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

    def ping(host)
      # Ping sites http://en.wikipedia.org/wiki/Sitemaps
      [ "http://www.google.com/webmasters/tools/ping?sitemap=http://#{host}/sitemap.xml",
        "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=http://#{host}/sitemap.xml",
        "http://submissions.ask.com/ping?sitemap=http://#{host}/sitemap.xml",
        "http://webmaster.live.com/ping.aspx?siteMap=http://#{host}/sitemap.xml" ].each do |url|
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
      def generate(host, &block)
        Generator.new(host).generate(&block)
      end
    end
    
  end
end
