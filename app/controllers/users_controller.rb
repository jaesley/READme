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
        if !current_user.authors.include? author
          current_user.authors << author
        end
        books_request = RestClient.get "http://www.goodreads.com/author/list/#{author.goodreads_id}?key=#{ENV['GOODREADS_API_KEY']}&v=2&per_page=200"
        books_xml = Hash.from_xml(books_request)
        books_xml['GoodreadsResponse']['author']['books']['book'].each do |book|
          pub_date = nil
          begin
          if book['publication_year'] != nil || book['publication_month'] != nil || book['publication_day'] != nil
            pub_date = "#{book['publication_year']}-#{book['publication_month']}-#{book['publication_day']}"
              if Date.parse(pub_date) && Date.parse(pub_date) >= Date.today
                title = book['title_without_series']
                goodreads_id = book['id']

                book['isbn'] ? isbn = book['isbn'] : isbn = book['isbn10']

                book = {title: title, goodreads_id: goodreads_id, isbn: isbn, author_id: author.id, publication_date: pub_date}
                author.books << Book.find_or_create_by(book)
              end
          end
          rescue
            next
          end
        end
      end
    end
    @user = User.find(params[:id]
  end
end
