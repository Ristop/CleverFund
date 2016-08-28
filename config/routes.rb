Rails.application.routes.draw do
    get 'notice' => 'notice#index'
    get 'notice/scan' => 'notice#scan'
	get 'notice/all.json' => 'notice#all'
	get 'notice/updated' => 'notice#get_number_of_not_queried_notices'
	get 'notice/getnew/:id' => 'notice#get_not_queried_notices'
	get 'notice/:id/edit/:tag' => 'notice#add_to_sorted'
	get 'notice/:id/edit/' => 'notice#add_to_unsorted'

	get 'notice/export' => 'notice#export'


	post '/tag/new' => 'notice#new_tag'
	delete '/tag/:id' => 'tag#destroy'
	get '/tag/all' => 'tag#all'
end
