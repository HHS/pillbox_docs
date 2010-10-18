class MessagePublisher < Facebooker::Rails::Publisher
  # START:ATTACK_NOTIFICATION
  helper :application

  def message_notification(message)
    send_as :notification
    recipients  message.defending_user
    from message.messaging_user.facebook_session.user
    fbml  <<-MESSAGE
  	  <fb:fbml> 
  	  #{message_result(message) }
  	  #{name message.defending_user} with a #{message.pill.name}.
  	  #{link_to "Diagnose them back", new_message_url}
  	  </fb:fbml>
  	MESSAGE
  end
  # END:ATTACK_NOTIFICATION
  
  # START:ATTACK_NOTIFICATION_EMAIL
  def message_notification_email(message)
    send_as :email
    recipients  message.defending_user
    from message.messaging_user.facebook_session.user
    title "You've been diagnosed!"
    fbml  <<-MESSAGE
  	  <fb:fbml> 
  	  #{message_result(message) }
  	  #{name message.defending_user} with a #{message.pill.name}.
  	  #{link_to "Diagnose them back", new_message_url}
  	  </fb:fbml>
  	MESSAGE
  end
  # END:ATTACK_NOTIFICATION_EMAIL
  

  
  def message_feed_template
    message_back=link_to("Prescribe!",new_message_url)
    one_line_story_template "{*actor*} {*result*} {*defender*} with a {*pill*}. #{message_back}"
    one_line_story_template "{*actor*} are helping to create a better (more medicated) world using Pharmville Rx. #{message_back}"
    short_story_template "{*actor*} has sought a second-opinion, and wants to re-consult.",
     "{*actor*} {*result*} {*defender*} with a {*pill*}."
    short_story_template "{*actor*} are practicing defensive medicine using Pharmville Rx.","#{message_back}"
  end
  
  def message_feed(message)
    send_as :user_action
    from message.messaging_user.facebook_session.user
    data :result=>message_result(message),
         :pill=>message.pill.name,
         :defender=>name(message.defending_user),
         :practice=>message.messaging_user.practice.name,
         :images=>[image(message.pill.image_name,pill_match_url(:message=>message.id))]
  end
    
  
  # START:NEW_BELT_NOTIFICATION
  def new_practice_notification(user)
    send_as :publish_stream
    recipients user.facebook_session.user
    title <<-TITLE
    Congratulations! You've been accepted to a prestigious #{user.practice.name} practice.
    #{link_to "You can prescribe better drugs!",pill_match_url(:message=>message.id)}
    TITLE
  end
  # END:NEW_BELT_NOTIFICATION

  #START:PROFILE_UPDATE
  def profile_update(user)
    send_as :profile
    recipients user
    @battles=user.battles
    profile render(:partial=>"profile",
      :assigns=>{:battles=>@battles})
    profile_main render(:partial=>"profile_narrow",
      :assigns=>{:battles=>@battles[0..3]})
  end
  #END:PROFILE_UPDATE
  
  
end
