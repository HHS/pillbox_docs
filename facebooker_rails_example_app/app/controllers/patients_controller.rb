class PatientsController < ApplicationController
  def index
    @caregiver = current_user
  end
end
