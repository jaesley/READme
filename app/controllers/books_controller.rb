class BooksController < ApplicationController
  def create
    if user_signed_in?
      current_user.generate_records
    end
  end
end
