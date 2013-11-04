require 'nokogiri'
require 'open-uri'

url = 'http://police.uoregon.edu/content/campus-daily-crime-log'

hrefs = Nokogiri::HTML(open(url))
		.css('a')
		.map{|link| 
			link['href'].gsub(" ", "%20")
		}.select{|href| 
			href.include?('Clery')
		}
puts hrefs	
hrefs.each do |href|
	slug = href.split("/").last
	cmd = "curl -s -o ./pdfs/#{slug} \"#{href}\""
	puts cmd
	`#{cmd}`
end
