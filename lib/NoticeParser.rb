module NoticeParser
	require './Notice'
	def NoticeParser.parseBroneering(mail_body)
		amount = /Summa: -(\d+\.\d+) EUR/.match(mail_body)[1]
		from_name = /Selgitus: \.\.\.\d+(.*)$/.match(mail_body)[1]
		from_email = "automailer@seb.ee"
		Notice.new(from_email, from_name, amount, false)
	end

	def NoticeParser.parseLaekmine(mail_body)
		begin
			amount = /Summa: \+(\d+\.\d+) EUR/.match(mail_body)[1]
			from_name = /Selgitus: (.*)$/.match(mail_body)[1]
			from_email = /EUR(.*)Viitenumber/m.match(mail_body)[1].strip
			Notice.new(from_email, from_name, amount, true)
		rescue NoMethodError
			puts mail_body
		end

	end

	def NoticeParser.parseValjaminek(mail_body)
		amount = /Summa: -(\d+\.\d+) EUR/.match(mail_body)[1]
		from_name = /Selgitus: (.*)$/.match(mail_body)[1]
		from_email = "automailer@seb.ee"
		Notice.new(from_email, from_name, amount, false)
	end
end
