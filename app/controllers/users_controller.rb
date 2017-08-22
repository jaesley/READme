class UsersController < ApplicationController
  def show
    if user_signed_in?
      authors_request = RestClient.get "http://www.goodreads.com/review/list/#{current_user.uid}?key=#{ENV['GOODREADS_API_KEY']}&v=2&sort=author&per_page=200&shelf=read"
      @body = Hash.from_xml(authors_request)
      @authors = []
      @body['GoodreadsResponse']['reviews']['review'].each do |review|
        author = {name: review['book']['authors']['author']['name'], goodreads_id: review['book']['authors']['author']['id']}
        @authors << author
      end
      @authors.uniq!.each do |author|
        author = Author.find_or_create_by(author)
        books_request = RestClient.get "http://www.goodreads.com/author/list/#{author.goodreads_id}?key=#{ENV['GOODREADS_API_KEY']}&v=2&per_page=200"
        if !current_user.authors.include? author
          current_user.authors << author
        end
      end
    end
    @user = current_user
  end
end
