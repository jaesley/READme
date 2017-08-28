class BooksController < ApplicationController
  include ApplicationHelper

  def create
    if user_signed_in?
      # generate_records(current_user)
    end
  end
end
