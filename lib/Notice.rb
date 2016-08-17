class Notice
	attr_accessor :from_email
	attr_accessor :from_name
	attr_accessor :amount
	attr_accessor :income

	@@notices = []

	def initialize(from_email, from_name, amount, income) # Constructor
			@from_email = from_email
			@from_name = from_name.strip
			@amount = amount
			@income = income
			@@notices.push(self)
	end

	def to_s
		income ? "[+#{amount}] - #{from_name} (#{from_email})"
		: "[-#{amount}] - #{from_name} (#{from_email})"
	end

end
