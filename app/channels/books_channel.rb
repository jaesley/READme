class BooksChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'books_channel'
  end
end
