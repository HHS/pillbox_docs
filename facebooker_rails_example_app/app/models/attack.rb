class Attack < ActiveRecord::Base
  # START:ASSOCIATIONS
  belongs_to :attacking_user, 
             :class_name=>"User", 
             :foreign_key=>:attacking_user_id
  belongs_to :defending_user, 
             :class_name=>"User", 
             :foreign_key=>:defending_user_id
  belongs_to :move
  # END:ASSOCIATIONS
  
  # START:ATTACK_NOTIFICATION
  after_create :send_attack_notification
  
  def send_attack_notification
    AttackPublisher.deliver_attack_notification(self) 
  rescue Facebooker::Session::SessionExpired
    # We can't recover from this error, but
    # we don't want to show an error to our user
  end
  # END:ATTACK_NOTIFICATION
  
  
  validates_presence_of :attacking_user_id, :defending_user_id, :move
  
  
  # START:HIT
  before_create :determine_hit

  def determine_hit
    returning true do
      # make it a hit 50% of the time
      self.hit = (rand(2) == 0) 
    end
  end
  # END:HIT
  
  # START:NOTIFY_DEFENDER
	def notify_defender
	  message = <<-MESSAGE
	  <fb:fbml> 
	  #{(hit? ? "hit" : "missed" ) }
	  you with a #{move.name}.
	  <a href="http://apps.facebook.com/karate_poke/attacks/new">
	  Attack them back</a>
	  </fb:fbml>
	  MESSAGE
	  attacking_user.facebook_session.send_notification(
	    [defending_user],message)
	end
	# END:NOTIFY_DEFENDER
	
end
