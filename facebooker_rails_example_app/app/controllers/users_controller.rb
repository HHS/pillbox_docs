class UsersController < ApplicationController
  def update
    saved = current_user.update_attribute(:nickname,params[:nickname])
    # the update was a success, show the closed_form
    render :partial=>"nickname", :locals=>{:closed=>saved}
  end
  
  def show
    @leaders = []
    @something = []
  end
end
