require 'singleton'

module SitemapGenerator
  class Helpers
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::ActiveRecordHelper

    def w3c_date(date)
     date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00") if date
    end
  end
end
