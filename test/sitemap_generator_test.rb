require 'test/test_helper'

#
# TODO split class
#
class SitemapGeneratorTest < Test::Unit::TestCase 

=begin
  context "Plugin" do
    should "require a valid configuration file" do
      SitemapGenerator::Options.should_receive(:load_options) { false }
      SitemapGenerator::Options.load_options
      SitemapGenerator::Generator.run
    end
  end
=end

  context "Generator" do
    should "find ActiveRecord models that are to be included in sitemap" do
      @model_path = File.join(RAILS_ROOT, 'app', 'models')

      generator = SitemapGenerator::Generator.new
      generator.find_models.should == [Admin::Post, Admin::Sales, Business, Post]
    end

    should "not allow sitemaps bigger than 10MB" do

    end

    should "not allow more than 50000 links per sitemap file" do

    end

    should "gzip sitemap" do

    end

    should "generate a valid XML file" do

    end

    should "sitemap URLs should be valid" do

    end
  end

  context "Ping" do
    # TODO cleanup
    should "should ping all major search engines" do
      urls = [
        'http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=http://aktagon.com/sitemap.xml',
        'http://www.google.com/webmasters/tools/ping?sitemap=http://aktagon.com/sitemap.xml',
        'http://submissions.ask.com/ping?sitemap=http://aktagon.com/sitemap.xml',
        'http://webmaster.live.com/ping.aspx?siteMap=http://aktagon.com/sitemap.xml'
      ].each do |url|
        FakeWeb.register_uri(:get, url, :body => "")
      end

      generator = SitemapGenerator::Generator.new.ping
    end
  end
end
