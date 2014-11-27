App::Application.routes.draw do

	root  'static_pages#home'
	post "static_pages/ajaxPages"
	match '/ajax', to: 'static_pages#ajaxPages', via: 'post'

	resources :users
	match '/workers',  to: 'users#workers',       via: 'get'
	resources :sessions, only: [:new, :create, :destroy]
	resources :arrivals

	match '/signup',  to: 'users#new',            via: 'get'
	match '/signin',  to: 'sessions#new',         via: 'get'
	match '/signout', to: 'sessions#destroy',     via: 'delete'
	
	match '/help',    to: 'static_pages#help',    via: 'get'

	resources :requistions
	match '/count', to: 'requistions#count', via: 'get'
	match '/count_all', to: 'requistions#count_all', via: 'get'
	match '/new', to: 'requistions#new', via: 'get'
	match '/requistions', to: 'requistions#index', via: 'get'
	match "/update_contracts", to: "requistions#update_contracts", via: 'get'	
	match "/update_date", to: "requistions#update_date", via: 'get'	
  	match 'requistions/:id/close', to: 'requistions#close', via: 'get'
  	match 'requistions/:id/raiting', to: 'requistions#raiting', via: 'get'
  	resources :contracts

  	resources :buildings
  	match 'buildings/:id/check_in', to: 'buildings#check_in', via: 'get'
  	match 'buildings/:id/check_out', to: 'buildings#check_out', via: 'get'
  	match 'no_build', to: 'buildings#no_build', via: 'get'

  	#match 'tests/:id', to: 'users#test', via: 'get', constraints: {id: /\d+/}

	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	# root 'welcome#index'

	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end
end
