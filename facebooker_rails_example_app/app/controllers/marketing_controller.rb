class MarketingController < ApplicationController
  skip_before_filter :ensure_authenticated_to_facebook
  def index
    
  end
end
