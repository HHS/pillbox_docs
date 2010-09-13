class MessagesController < ApplicationController
  # START:TAB
skip_before_filter :ensure_authenticated_to_facebook
#  skip_before_filter :ensure_authenticated_to_facebook, :only => [:index,:tab, :selection_window, :secret_message_form]
  
  
  # END:TAB
  # START:NEW_ATTACK
  def new
   @pill_categories = PillCategory.all :order=>'title DESC' 
   
   @pill_category = PillCategory.find_by_title(params[:category]) 
   @pill_category ||= @pill_categories.first
    
    if params[:from]
      current_user.update_attribute(:sensei,User.find(params[:from]))
    end
  end
  # END:NEW_ATTACK

  def create
    if params[:ids].blank?
      flash[:error] = "You forgot to tell me who you wanted to prescribe this to!"      
    else    
      message = Message.new((params[:message] || {}).merge(:messaging_user=>current_user ))

      hits = []
      misses = []
      # START:CALL_UPDATE_PROFILE
      for id in params[:ids]
        m = message.dup
        m.defending_user = User.for(id)
        if m.save
           if m.hit?
             current_user.increment :total_hits 
             if current_user.practice.should_be_upgraded?(current_user)
               current_user.practice=current_user.practice.next_practice
               current_user.notify_of_new_practice
             end
           end
           current_user.save!
         end
        
        
        MessagePublisher.deliver_profile_update(message.defending_user) rescue nil

        if message.hit?
          hits << message
        else
          misses << message
        end
      end
      # END:CALL_UPDATE_PROFILE
      MessagePublisher.deliver_profile_update(current_user) rescue nil
      MessagePublisher.deliver_message_feed(message) rescue nil    
      flash[:notice] = "Your prescription resulted in #{hits.size} " +
        (hits.size==1 ? "hit" : "hits") +
        " and #{misses.size} "+
        (misses.size == 1 ? "miss" : "misses") + "."
    end
    redirect_to new_message_path
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
      flash[:notice]="You haven't prescribed Viagra to anyone yet."+
        " Hurry up so you can meet your hospital's quota."
      redirect_to new_message_path
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
  
  def secret_message_form 
      pill = Pill.find(params[:pill])
      @pill_message = pill.build_message      
      render :partial => 'form.fbml.erb', :layout => false
      return
  end
  
  def selection_window
    pill_category = PillCategory.find :first, :conditions => {:title=> params[:category].gsub("_"," ")}, :include=>[:pills]
    txt_to_render =  render_to_string :partial=>'selection_window.fbml', :object=>pill_category
    render :text => txt_to_render, :layout => false
    return
  end
  
  

end
