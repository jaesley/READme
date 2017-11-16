class PagesController < ApplicationController
  def index
    # if current_user
      # redirect_to user_path(current_user.id)
    # else
    #   redirect_to new_user_registration_path
    # end
    redirect_to user_path(User.first.id)
  end
end
