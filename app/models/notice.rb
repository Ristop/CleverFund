class Notice < ActiveRecord::Base
    def to_s
        income ? "[+#{amount}] - #{from_name} (#{from_email})"
        : "[-#{amount}] - #{from_name} (#{from_email})"
    end
end
