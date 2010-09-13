# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_karate_poke_session',
  :secret      => 'b4ca678fbd606449964c470014deb52f284c2781c0690a590299d28ca6834b7a82c75329d4c83e69cb20ea10be17760fbb3502a2456f84c1d0cf9e34912c86ee'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
