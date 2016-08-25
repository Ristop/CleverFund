class NoticeController < ApplicationController
    respond_to :html, :xml, :json
    require 'gmail_reader'

    @@number_of_new_notices = 0
	@@number_of_sorted_notices = 0

	# Updates the count of new notices and sorted notices
	# *Returns* :
	# 	- New notices as array of Notice objects
	# 	- Sorted notices as array of Notice objects
    def index
        @new_notices = Notice.where(sorted: false).all
		@sorted_notices = Notice.where(sorted: true).all
		@@number_of_new_notices = @new_notices.count
		@@number_of_sorted_notices = @sorted_notices.count
		return @new_notices, @sorted_notices
    end

	# Scans for new notices through Gmail API if latest_message_epoch_time is set
	# *Returns* :
	# 	- No content
    def scan
        if AppVariable.exists?(name: 'latest_message_epoch_time')
            thr = Thread.new { GmailReader.read_bank_notices(AppVariable.find(1).value) }
        end
        head :no_content
    end

	# Calculates number of new notices that have not been shown yet
	# *Returns* :
	# 	- Number of new notices as string
    def get_number_of_not_queried_notices
        number_of_new_notices = Notice.where(sorted: false).all.count - @@number_of_new_notices
        render text: number_of_new_notices
    end

	# Queries new notices that have not yet been shown
	# *Returns* :
	# 	- New notices as array of Notice objects
    def get_not_queried_notices
        @num = params[:id]
        @new_notices = Notice.where(sorted: false).last(@num.to_i).reverse
        @@number_of_new_notices += @num.to_i
        respond_with(@new_notices)
    end

	# Changes the sorted column for a given Notice objects
	# If Notice object has sorted value true, it will be changed to false and
	# vice versa
	# *Returns* :
	# 	- No content
    def update_sorted_status
        @notice = Notice.find(params[:id])
		if (@notice.sorted)
			@notice.update_attribute(:sorted, false)
			@@number_of_new_notices += 1
			@@number_of_sorted_notices -= 1
		else
			@notice.update_attribute(:sorted, true)
			@@number_of_new_notices -= 1
			@@number_of_sorted_notices += 1
		end
		head :no_content
    end
end
