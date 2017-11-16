class BooksController < ApplicationController
  include ApplicationHelper

  def create
    current_user = User.first
    if user_signed_in?
      current_user.generate_authors_all_pages
      current_user.authors.each do |author|
        current_user.generate_books(author)
      end
    end
  end

  def show
    @book = Book.find(params[:id])
  end
end
