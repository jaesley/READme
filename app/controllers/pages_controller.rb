class PagesController < ApplicationController
  def index
    if user_signed_in?
      request = RestClient.get "http://www.goodreads.com/review/list/#{current_user.uid}?key=#{ENV['GOODREADS_API_KEY']}&v=2&sort=author&per_page=200&shelf=read"
      @body = Hash.from_xml(request)
      @authors = []
      @body['GoodreadsResponse']['reviews']['review'].each do |review|
        author = {name: review['book']['authors']['author']['name'], goodreads_id: review['book']['authors']['author']['id']}
        @authors << author
      end
      @authors.uniq!
    end
  end
end
