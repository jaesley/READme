require 'pp'

class PagesController < ApplicationController
  def index
    request = RestClient.get "http://www.goodreads.com/review/list/#{current_user.uid}?key=#{ENV['GOODREADS_API_KEY']}&v=2&sort=author&per_page=200&shelf=read"
    body = Hash.from_xml(request).to_json
    pp body
  end
end
