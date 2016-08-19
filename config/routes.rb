Rails.application.routes.draw do
	get 'notice' => 'notice#index'
	get 'notice/scan' => 'notice#scan'
end
