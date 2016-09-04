module ExcelExporter
    require 'roo'
    require 'rubyXL'

    @@month_names = %w(
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
    )

    def self.insert_notice(date, amount, tag)
        xlsx = Roo::Spreadsheet.open('/Users/ristoparnapuu/Dropbox/Programmeerimine/CleverFund/lib/budget.xlsm')
        xlsx = Roo::Excelx.new('/Users/ristoparnapuu/Dropbox/Programmeerimine/CleverFund/lib/budget.xlsm')

        workbook = RubyXL::Parser.parse('/Users/ristoparnapuu/Dropbox/Programmeerimine/CleverFund/lib/budget.xlsm')
        worksheet = workbook[@@month_names[date.mon - 1]]
        @row = nil
        @column = nil
        xlsx.sheet(@@month_names[date.mon - 1]).row(1).each_with_index do |row_name, i|
            @row = i if tag == row_name
        end
        xlsx.sheet(@@month_names[date.mon - 1]).column(1).each_with_index do |column_name, i|
            if column_name.is_a?(Date) && date.mday == column_name.mday
                @column = i
            end
        end
		puts "Exporting to excel: " + date.mday.to_s + "." + date.mon.to_s + " - " + tag + " " + amount.to_s
        # worksheet[@column][@row].change_contents(amount, worksheet[@column][@row].formula)
        # worksheet.add_cell(@column, @row)
        # worksheet[@column][@row].change_contents(amount, worksheet[@column][@row].formula)
        # workbook.save
    end

    insert_notice(Date.new(2016, 8, 26), 30, 'Hookah')
end
