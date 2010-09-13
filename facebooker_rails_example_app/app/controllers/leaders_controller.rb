class LeadersController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user

  # START:INDEX
  def index
    @leaders = User.paginate(:order=>"total_hits desc",
                             :page=>(params[:page]||1))
  end
  # END:INDEX
end
