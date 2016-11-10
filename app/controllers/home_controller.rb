class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to games_path
    else
      redirect_to new_user_registration_path
    end
  end
end