class AttacksController < ApplicationController
  # START:TAB
  skip_before_filter :ensure_authenticated_to_facebook  , :only => [:index,:tab]
  # END:TAB
  # START:NEW_ATTACK
  def new
    if params[:from]
      current_user.update_attribute(:sensei,User.find(params[:from]))
    end
  end
  # END:NEW_ATTACK

  def create
    if params[:ids].blank?
      flash[:error] = "You forgot to tell me who you wanted to attack!"      
    else
    
      attack = Attack.new(params[:attack])
      hits = []
      misses = []
      # START:CALL_UPDATE_PROFILE
      for id in params[:ids]
        attack = current_user.attack(User.for(id),attack.move)
        AttackPublisher.deliver_profile_update(attack.defending_user) rescue nil
        
        if attack.hit?
          hits << attack
        else
          misses << attack
        end
      end
      # END:CALL_UPDATE_PROFILE
      AttackPublisher.deliver_profile_update(current_user) rescue nil
      AttackPublisher.deliver_attack_feed(attack) rescue nil    
      flash[:notice] = "Your attack resulted in #{hits.size} " +
        (hits.size==1 ? "hit" : "hits") +
        " and #{misses.size} "+
        (misses.size == 1 ? "miss" : "misses") + "."
    end
    redirect_to new_attack_path
  end
  
  # START:TAB
  def tab
    @user = User.for(params[:fb_sig_profile_user])
    @battles = @user.battles
    render :action=>"tab",:layout=>"tab"
  end
  # END:TAB

  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
       redirect_to leaders_path and return if @user.nil?
    end
    # If we don't have a user, require add
    if @user.blank?
      ensure_authenticated_to_facebook   
      return 
    end
    
    @battles = @user.battles
    # START:COMMENTS
    if @battles.blank?
      flash[:notice]="You haven't battled anyone yet."+
        " Why don't you attack your friends?"
      redirect_to new_attack_path
    else
      @comments = @user.comments
    end
    # END:COMMENTS
  end

  # START:UPDATE_PROFILE
  def update_profile(user)
    unless user.facebook_session.blank?
      battles=user.battles
      facebook_user=Facebooker::User.new(user.facebook_id)
      content= 
       render_to_string(:partial=>"profile",:locals=>{:battles=>battles})
      action= 
       render_to_string(:partial=>"profile_action",:locals=>{:user=>user})
      mobile= 
       render_to_string(:partial=>"mobile_profile",:locals=>{:battles=>battles})
      facebook_user.set_profile_fbml(content,mobile,action)
    end
  end
  # END:UPDATE_PROFILE

  # START:DEFAULT_URL
  def default_url_options(options)
    {:canvas=>true}
  end
  # END:DEFAULT_URL

end
