ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }
  map.resource  :session
  map.resources :restaurants
  map.resources :images
  map.resources :reviews
  map.resources :contributed_images
  map.resources :topics
  map.resources :review_comments

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.login_as '/login_as/:user', :controller => 'sessions', :action => 'login_as'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate "/activate/:activation_code", :controller => "users", :action => "activate", :activation_code => nil
  map.reset_password "/user/reset_password", :controller => "users", :action => "reset_password"
  map.process_reset_password "/user/process/reset_password/", :controller => "users", :action => "process_reset_password"
  map.change_password "/user/change_password/:token", :controller => "users", :action => "change_password", :token => nil
  map.save_new_password "/user/save_new_password/", :controller => "users", :action => "save_new_password"

  map.restaurant_long '/restaurants/:name/:id', :controller => 'restaurants', :action => 'show'
  map.most_loved_places '/at_most_loved_places', :controller => 'home', :action => 'most_loved_places'
  map.recently_reviewed_places '/at_recently_reviewed_places', :controller => 'home', :action => 'recently_reviewed_places'
  map.who_wanna_go_place '/at/:name/and_see_who_havent_been_there_before/:id', :controller => 'home', :action => 'who_havent_been_there_before'

  map.facebook_connect '/facebook/connect', :controller => 'users', :action => 'facebook_connect'
  map.facebook_connect_update '/facebook/connect/update', :controller => 'users', :action => 'update_facebook_connect_status'
  map.facebook_publish '/facebook/publish/:story/:id', :controller => 'facebook_connect', :action => 'publish_story'
  map.facebook_account_status_update '/user/facebook_account/update_status', :controller => 'users', :action => 'update_facebook_connect_account_status'

  map.admin '/dashboard', :subdomain => 'admin', :controller => 'admin', :action => 'index'

  map.user_long '/users/:login/:id', :controller => 'users', :action => 'show'
  map.updates '/activities', :controller => 'stuff_events', :action => 'show'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
