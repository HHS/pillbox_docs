class AttackPublisher < Facebooker::Rails::Publisher
  # START:ATTACK_NOTIFICATION
  helper :application

  def attack_notification(attack)
    send_as :notification
    recipients  attack.defending_user
    from attack.attacking_user.facebook_session.user
    fbml  <<-MESSAGE
  	  <fb:fbml> 
  	  #{attack_result(attack) }
  	  #{name attack.defending_user} with a #{attack.move.name}.
  	  #{link_to "Attack them back", new_attack_url}
  	  </fb:fbml>
  	MESSAGE
  end
  # END:ATTACK_NOTIFICATION
  
  # START:ATTACK_NOTIFICATION_EMAIL
  def attack_notification_email(attack)
    send_as :email
    recipients  attack.defending_user
    from attack.attacking_user.facebook_session.user
    title "You've been attacked!"
    fbml  <<-MESSAGE
  	  <fb:fbml> 
  	  #{attack_result(attack) }
  	  #{name attack.defending_user} with a #{attack.move.name}.
  	  #{link_to "Attack them back", new_attack_url}
  	  </fb:fbml>
  	MESSAGE
  end
  # END:ATTACK_NOTIFICATION_EMAIL
  

  
  def attack_feed_template
    attack_back=link_to("Join the Battle!",new_attack_url)
    one_line_story_template "{*actor*} {*result*} {*defender*} with a {*move*}. #{attack_back}"
    one_line_story_template "{*actor*} are doing battle using Karate Poke. #{attack_back}"
    short_story_template "{*actor*} engaged in battle.",
     "{*actor*} {*result*} {*defender*} with a {*move*}."
    short_story_template "{*actor*} are doing battle using Karate Poke..","#{attack_back}"
  end
  
  def attack_feed(attack)
    send_as :user_action
    from attack.attacking_user.facebook_session.user
    data :result=>attack_result(attack),
         :move=>attack.move.name,
         :defender=>name(attack.defending_user),
         :belt=>attack.attacking_user.belt.name,
         :images=>[image(attack.move.image_name,new_attack_url)]
  end
    
  
  # START:NEW_BELT_NOTIFICATION
  def new_belt_notification(user)
    send_as :story
    recipients user.facebook_session.user
    title <<-TITLE
    Congratulations! You've earned a #{user.belt.name} belt.
    #{link_to "Try out your new moves",new_attack_url}
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
