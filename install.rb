puts IO.read(File.join(File.dirname(__FILE__), 'INSTALL'))

# Install hook code here
require 'ftools'

if !File.exist?(Options::CONFIG_FILE)
  File.open(Options::CONFIG_FILE, 'w') do |file|
    file << "domain:                      # For example: 'aktagon.com'"
    file << "change_frequency: weekly"
    file << "limit: 5000"
    file << "ping: true"
    file << "priority: 1.0"
  end
end

if !File.exist?(Options::XML_STYLESHEET)
  File.copy(File.join(File.dirname(__FILE__), "sitemap.xsl"), Options::XML_STYLESHEET)
end

p "SitemapGenerator installed."
p "NOTE: You need to specify the domain of your application in #{Options::CONFIG_FILE}"
