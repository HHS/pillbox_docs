class Message < ActiveRecord::Base
  # START:ASSOCIATIONS
  belongs_to :messaging_user, 
             :class_name=>"User", 
             :foreign_key=>:messaging_user_id
  belongs_to :defending_user, 
             :class_name=>"User", 
             :foreign_key=>:defending_user_id
  belongs_to :pill
  # END:ASSOCIATIONS
  
  attr_accessor :decrypt_key, :preset_message
  # START:ATTACK_NOTIFICATION
  after_create :send_message_notification
  before_create lambda {|m| m.encrypt! if m.encrypt_flag; true }
  before_update :decrypt_if_key
  
  
  def send_message_notification
    MessagePublisher.deliver_message_notification(self) 
  rescue Facebooker::Session::SessionExpired
    # We can't recover from this error, but
    # we don't want to show an error to our user
  end
  
  
  validates_presence_of :messaging_user_id, :defending_user_id, :pill
  
  attr_accessor :encrypt_flag
  # START:HIT
  before_create :determine_hit

  def determine_hit
    returning true do
      # make it a miss 10% of the time
      self.hit = (rand(10) >= 1) 
    end
  end
  # END:HIT
  
  # START:NOTIFY_DEFENDER
	def notify_defender
	  message = <<-MESSAGE
	  <fb:fbml> 
	  #{(hit? ? "cured" : "exacerbated" ) }
	  you with a #{pill.name}.
	  <a href="http://apps.facebook.com/pharmvillerx/messages/new">
	  Send a Pill Back</a>
	  </fb:fbml>
	  MESSAGE
	  messaging_user.facebook_session.send_notification(
	    [defending_user],message)
	end
	
	def encrypt!
    write_attribute :crypted, self['cleartext'].tr("a-z", "b-za")
  end
  
  def to_s    
    crypted.blank? ? (@cleartext ||= "") : crypted
  end
  
  def decrypt_if_key(key = nil)
    # "An encrypted String".tr "b-za", "a-z" #=> cleartext!
    # but it's just easier to delete the crypted.
    key ||= self[:decrypt_key]
    if key == pill_id.to_s # or /match/i pill.accepted_names
      self.write_attribute(:crypted, nil)
    end
  end
	
end
