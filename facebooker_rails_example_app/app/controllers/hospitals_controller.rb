class HospitalsController < ApplicationController
  def show
    @sensei = User.find(params[:id])
    @disciples = @sensei.disciples
    disciple_ids = @disciples.map(&:facebook_id).join(",")
    users=current_user.facebook_session.fql_query(
     "select uid,hometown_location from user "+
     "where uid in (#{disciple_ids})")

    @user_hash={}
    for user in users
      @user_hash[user.uid]=user
    end
  end

end
