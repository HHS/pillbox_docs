ActionController::Routing::Routes.draw do |map|

  # See how all your routes lay out with "rake routes"
  map.resources :invitations
  map.resources :messages, :collection=>{:secret_message_form=>:get, :selection_window=>:get}

  # START:COMMENTS
  map.resources :comments
  # END:COMMENTS

  # START:DOJOS
  map.resources :hospitals
  # END:DOJOS

  map.resources :users

  # START:HOMEPAGES
  map.root :controller=>'users', :action=>'show'
  map.battles '',:controller=>"messages", 
                 :conditions=>{:canvas=>true}
  map.marketing_home '',:controller=>"marketing"
  # END:HOMEPAGES
  
  map.resources :leaders
  
  map.resources :patients
  map.resources :pills, :only=>[:index], :collection=>{:lookup=>:get, :match=>:get}
  map.lookup_pill 'lookup/pill/:id', :controller=>'pills', :action=>'lookup'
    
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
