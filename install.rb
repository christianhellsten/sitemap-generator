# Install hook code here

if !File.exist?(Options::CONFIG_FILE)
  File.open(Options::CONFIG_FILE, 'w') do |file|
    file << "domain:                      # For example: 'aktagon.com'"
    file << "change_frequency: weekly"
    file << "limit: 5000"
    file << "priority: 1.0"
  end
end

puts "SitemapGenerator installed."
puts "NOTE: You need to specify the domain of your application in #{Options::CONFIG_FILE}"
