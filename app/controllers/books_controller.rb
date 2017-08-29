class BooksController < ApplicationController
  include ApplicationHelper

  def create
    if user_signed_in?
      book = generate_book({title: 'Thing2', goodreads_id: '1', publication_date: Date.today, author_id: Author.all.sample.id})
      if book.save
        ActionCable.server.broadcast 'books_channel',
          title: book_obj.title,
          author: book_obj.author.name
        # head :ok
      end
      # generate_records(current_user)
    end
  end

  def show
    @book = Book.find(params[:id])
  end
end
