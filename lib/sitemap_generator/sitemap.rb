module SitemapGenerator
  class Sitemap
    VALID_CHANGE_FREQ = [
      :always,
      :hourly,
      :daily,
      :weekly,
      :monthly,
      :yearly,
      :never
    ]
    
    def initialize(host, xml)
      @xml = xml
      @host = host
    end

    def add(model_instance, priority = nil, change_freq = nil)
      last_modified = model_instance.read_attribute(:updated_on) || model_instance.read_attribute(:updated_at)
      
      if last_modified.nil?
        last_modified = model_instance.read_attribute(:created_on) || model_instance.read_attribute(:created_at)
      end

      if !VALID_CHANGE_FREQ.include?(change_freq.to_sym) && !change_freq.nil?
        raise "Invalid change frequency #{change_freq}, should be one of #{VALID_CHANGE_FREQ}" 
      end

      @xml.url do
        @xml.loc "http://#{@host}#{Helpers.instance.url_for(model_instance)}"
        @xml.lastmod Helpers.instance.w3c_date(last_modified) if last_modified
        @xml.changefreq change_freq.to_s if change_freq
        @xml.priority priority if priority
      end  
    end
  end
end
