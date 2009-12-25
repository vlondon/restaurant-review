# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = {:host => 'servicedev1.net'}

# google map API key
MAP_API_KEY = 'ABQIAAAAFNm78CTt6Ba6XsBkWZHE3hRXwWGis4ehQYwFPWsPJASMY_J0qBTSdP47_yO6GocUwBOmC-5rdxE2Bw'