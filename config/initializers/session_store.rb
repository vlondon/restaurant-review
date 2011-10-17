# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_welltreat_us_prod_v2',
  :secret      => 'changed3589d4281cd767676773989898d08989085fbc60d2c5a326ac1d1dd22a5cef651f81b59b4519834a8f05fe663c8b9921a7a47944a1772a9d3e340806bc4b7e3e9350b8f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
