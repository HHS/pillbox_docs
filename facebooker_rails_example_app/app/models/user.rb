class User < ActiveRecord::Base

  # START:BELT
  belongs_to :practice do |p|
    def should_be_upgraded?
      debugger
      p.should_be_upgraded?(proxy_owner) 
    end
  end
	# END:BELT  
  # START:ASSOCIATIONS
  has_many :messages, :foreign_key=>:messaging_user_id
  has_many :defenses, :class_name=>"Message", :foreign_key=>:defending_user_id
  # END:ASSOCIATIONS
  # START:SENSEI
  belongs_to :sensei, :class_name=>"User", :foreign_key=>:sensei_id
  has_many :disciples, :class_name=>"User", :foreign_key=>:sensei_id
	# END:SENSEI
  # START:COMMENTS
  has_many :comments
  has_many :made_comments, :class_name=>"Comment", :foreign_key=>:poster_id
  # END:COMMENTS
  
  has_many :patients, :after_add=>proc{|proxy_owner,p| proxy_owner.increment!(:patients_count) }

  # START:INITIAL_BELT
  before_create :set_initial_practice
  after_create do |user|
    10.times { 
      patient = user.patients.create
      }
  end
    
	
	def set_initial_practice
	  # GOTCHA: make sure you've run db/seeds.rb using rake db:setup
	  self.practice = Practice.initial_practice
	end
  # END:INITIAL_BELT

  
# START:BATTLES
def battles(page=1)
  page ||= 1
  Message.paginate(
    :conditions=>
      ["messaging_user_id=? or defending_user_id=?",
      self.id,self.id],
    :include=>[:messaging_user,:defending_user,:pill],
    :order=>"messages.created_at desc",
    :page => page,
    :per_page => 5)
end
# END:BATTLES

  # START:AVAILABLE_PILLS
  def available_pills
    @all_available_pills ||= PillCategory.all.map{|pc| [pc.title, pc.pills.map{|p| [p.name, p.id] }] }
  end
  
  def emergency_room_pillbox
    Pill.find(:all,
      :conditions=>["drug_class <= ?",practice.level],
      :order=>"name asc")
  end
	# END:AVAILABLE_MOVES
	
	
	# START:STORY
  def notify_of_new_practice
    MessagePublisher.deliver_new_practice_notification(self)
  rescue Facebooker::Session::TooManyUserCalls=>e
    nil
  end
	# END:STORY

  # START:COMMENT_ON
  def comment_on(user,body)
    made_comments.create!(:user=>user,:body=>body)
  end
  # END:COMMENT_ON
  
	# START:DISCIPLES
  def friends_with_senseis(friends_facebook_ids)
	  User.find(:all, 
	    :conditions=>["facebook_id in (?) and sensei_id is not null",
	                  friends_facebook_ids])
  end
	# END:DISCIPLES

  def hometown
    fb_user = Facebooker::User.new(facebook_id)
    location = fb_user.hometown_location
    text_location = "#{location.city} #{location.state}"
    text_location.blank? ? "an undisclosed location" : text_location
  end

	
  # START:USER_FOR
	def self.for(facebook_id,facebook_session=nil)
		returning find_or_create_by_facebook_id(facebook_id) do |user|
			unless facebook_session.nil?
				user.store_session(facebook_session.session_key) 
			end
		end
	end
  # END:USER_FOR
  
  # START:STORE_SESSION
	def store_session(session_key)
	  if self.session_key != session_key
			update_attribute(:session_key,session_key) 
		end
	end
  # END:STORE_SESSION
  
  def hometown(fb_user)
    fb_user ||= Facebooker::User.new(facebook_id)
    location = fb_user.hometown_location
    text_location = "#{location.city} #{location.state}" unless location.blank?
    text_location.blank? ? "an undisclosed location" : text_location
  end
  
  	
  def facebook_session
    @facebook_session ||=  # <label id="code.conditional-assign" />
      returning Facebooker::Session.create do |session| # <label id="code.returning" />
        session.secure_with!(session_key,facebook_id,1.day.from_now) # <label id="code.secure-with" />
        Facebooker::Session.current=session
    end
  end

  def funding
    50000
  end
  def reputation
    "Excellent"
  end
  
end
