require 'json'

def pdf_to_json(filename)
	records = []
	html = `pdftohtml -stdout "#{filename}"`
	html.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '') 
	html.encode!('UTF-8', 'UTF-16')
	lines = html.split("\n")	
	lines.each_with_index do |line, index|
		if line.include?('13-') or line.include?('N/A') # so. fragile.
			record = %w{nature case_number reported_date occured_date location disposition}.map(&:to_sym)
				.zip(lines[index-1..index+4]) # attach column names to column data
				.map{|item|
					[item.first, item.last.gsub("<br>", "")] # cleanup pdftohtml artifacts	
				}.inject({}){|obj, item|
					obj[item.first] = item.last # make a hash
					obj
				}
			# the following is also fragile. looks for dates by slash count in those columns. yuck.
			if record[:reported_date].split("/").count == 3
				records << record 
			else
				if record[:nature].include?("<META")
					# no op, this is a page header
				else
					puts "BROKEN! #{record}"
				end
			end
		end
	end
	records
end

File.open('output.json', 'w') do |output|
	Dir.glob("./pdfs/*").each do |file|
		pdf_to_json(file).each do |record|
			output.puts record.to_json
		end
	end
end