class TagController < ApplicationController
	respond_to :html, :xml, :json
	protect_from_forgery

    def new
        @tag = Tag.new
		redirect_to "/notice"
 	end

	def destroy
		Tag.find(params[:id]).destroy
		head :no_content
	end

	def all
		@tags = Tag.all
		respond_with(@tags)
	end
end
