class NoticeController < ApplicationController
	require 'gmail_reader'
	def index

	end

	def scan
		thr = Thread.new { GmailReader.fetchData }.join
		redirect_to '/notice'
	end
end
