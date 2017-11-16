class UsersController < ApplicationController
  def show
  #   if !user_signed_in? && params[:id] != current_user.id
  #     redirect_to root_path
  #   else
  #     @user = current_user
  #   end
    @user = User.first
  end
end
