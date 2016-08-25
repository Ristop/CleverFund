Rails.application.routes.draw do
    get 'notice' => 'notice#index'
    get 'notice/scan' => 'notice#scan'
	get 'notice/all.json' => 'notice#all'
	get 'notice/updated' => 'notice#get_number_of_not_queried_notices'
	get 'notice/getnew/:id' => 'notice#get_not_queried_notices'
	get 'notice/:id/edit' => 'notice#update_sorted_status'
end
