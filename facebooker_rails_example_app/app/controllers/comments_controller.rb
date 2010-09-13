class CommentsController < ApplicationController
  def create
    comment_receiver = User.find(params[:comment_receiver])
    current_user.comment_on(comment_receiver,params[:body])
    if request.xhr?
      @comments=comment_receiver.comments(true)
      render :json=>{:ids_to_update=>[:all_comments,:form_message],
              :fbml_all_comments=>render_to_string(:partial=>"comments"),
              :fbml_form_message=>"Your comment has been added."}
    else
      redirect_to battles_path(:user_id=>comment_receiver.id)
    end
  end

end
