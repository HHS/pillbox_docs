class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  protect_from_forgery  
  ensure_authenticated_to_facebook  
  
  # START:HELPER_ATTR
	helper_attr :current_user
  # END:HELPER_ATTR

  attr_accessor :current_user
  before_filter :set_current_user

  # START:CURRENT_USER
  def set_current_user
    set_facebook_session
    # if the session isn't secured, we don't have a good user id
    if facebook_session and 
       facebook_session.secured? and 
       !request_is_facebook_tab?
      self.current_user = User.for(facebook_session.user.to_i,facebook_session) 
    end
  end
  # END:CURRENT_USER

end
