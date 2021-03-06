module NoticeParser
    require 'Notice'
    def self.parseBroneering(mail_body, message_internal_date)
        amount = /Summa: -(\d+\.\d+) EUR/.match(mail_body)[1]
        from_name = /Selgitus: \.\.\.\d+(.*)$/.match(mail_body)[1]
        from_email = 'automailer@seb.ee'
        new_notice = Notice.new(from_email: from_email, tag: '', from_name: from_name, sorted: false, epoch_time: message_internal_date, amount: amount, income: false)
        new_notice.save
    end

    def self.parseLaekmine(mail_body, message_internal_date)
        amount = /Summa: \+(\d+\.\d+) EUR/.match(mail_body)[1]
        from_name = /Selgitus: (.*)$/.match(mail_body)[1]
        from_email = /EUR(.*)Viitenumber/m.match(mail_body)[1].strip
        new_notice = Notice.new(from_email: from_email, tag: '', from_name: from_name, sorted: false, epoch_time: message_internal_date, amount: amount, income: true)
        new_notice.save
    end

    def self.parseValjaminek(mail_body, message_internal_date)
        amount = /Summa: -(\d+\.\d+) EUR/.match(mail_body)[1]
        from_name = /Selgitus: (.*)$/.match(mail_body)[1]
        from_email = 'automailer@seb.ee'
        new_notice = Notice.new(from_email: from_email, tag: '', from_name: from_name, sorted: false, epoch_time: message_internal_date, amount: amount, income: false)
        new_notice.save
    end

    def self.parseTagasimakse(mail_body, message_internal_date)
        amount = /Summa: \+(\d+\.\d+) EUR/.match(mail_body)[1]
        from_name = /Selgitus: (.*)$/.match(mail_body)[1]
        from_email = /EUR(.*)Selgitus/m.match(mail_body)[1].strip
        new_notice = Notice.new(from_email: from_email, tag: '', from_name: from_name, sorted: false, epoch_time: message_internal_date, amount: amount, income: true)
        new_notice.save
    end
end
