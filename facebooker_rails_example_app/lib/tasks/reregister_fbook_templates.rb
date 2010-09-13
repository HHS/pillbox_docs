namespace :facebooker do
  
  rake "reregister" do
    MessagePublisher.send(ENV['register_method']) # || MessagePublisher)
  end
end