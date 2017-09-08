class BooksController < ApplicationController
  include ApplicationHelper

  def create
    if user_signed_in?
      current_user.generate_records(current_user)
    end
  end

  def show
    @book = Book.find(params[:id])
  end
end
