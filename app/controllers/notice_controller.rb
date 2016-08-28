class NoticeController < ApplicationController
    respond_to :html, :xml, :json
    require 'gmail_reader'
    require 'excel_exporter'

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
		@tags = Tag.all
        [@new_notices, @sorted_notices, @tags]
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

    # Export sorted notices to excel file
    # *Returns* :
    # 	- No content
    def export
        @sorted_notices = Notice.where(sorted: true).all
        thr = Thread.new do
            @sorted_notices.each do |notice|
                ExcelExporter.insert_notice(DateTime.strptime(notice.epoch_time, '%s'), notice.amount, notice.tag)
            end
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

	# Changes Notice objects sorted value to true and adds tag
	# *Returns* :
	# 	- No content
    def add_to_sorted
        @notice = Notice.find(params[:id])
        if !@notice.sorted
            @notice.update_attribute(:sorted, true)
			@notice.update_attribute(:tag, params[:tag])
            @@number_of_new_notices -= 1
            @@number_of_sorted_notices += 1
        end
        head :no_content
    end

	# Changes Notice objects sorted value to false and removes tag
	# *Returns* :
	# 	- No content
	def add_to_unsorted
        @notice = Notice.find(params[:id])
        if @notice.sorted
            @notice.update_attribute(:sorted, false)
			@notice.update_attribute(:tag, "")
            @@number_of_new_notices += 1
            @@number_of_sorted_notices -= 1
        end
        head :no_content
    end

	def new_tag
		puts(params[:tag][:name])
		@tag = Tag.new(name: params[:tag][:name])
		@tag.save
		redirect_to "/notice"
	end
end
