require 'pp'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:goodreads]

  has_many :follows
  has_many :authors, through: :follows
  has_many :books, through: :authors

  def self.from_omniauth(auth)
     pp auth
     where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      #  p user
       p "*" * 1000
       user.provider = auth.provider
       user.uid = auth.uid
       user.user_name = auth.info.user_name
       user.password = Devise.friendly_token[0,20]
       user.save
     end
   end

   def email_changed?
     false
   end

   def generate_records
     generate_authors
     generate_books
   end

   def generate_authors
     authors_request = RestClient.get "http://www.goodreads.com/review/list/#{current_user.uid}?key=#{ENV['GOODREADS_API_KEY']}&v=2&sort=author&per_page=200&shelf=read"
     authors = generate_author_hashes(Hash.from_xml(authors_request))
     authors.each do |author|
       generate_author(author)
     end
   end

   def generate_author(author)
     author = Author.where(goodreads_id: author[:goodreads_id]).first_or_create.update_attributes(name: author[:name])
     generate_follow(author)
   end

   def generate_follow(author)
     if !current_user.authors.include? author
       current_user.authors << author
     end
   end

   def generate_author_hashes(body)
     authors = []
     body['GoodreadsResponse']['reviews']['review'].each do |review|
       author = generate_author_hash(review)
       authors << author
     end
     authors.uniq
   end

   def generate_author_hash(review)
     name = review['book']['authors']['author']['name']
     goodreads_id = review['book']['authors']['author']['id']
     {name: name, goodreads_id: goodreads_id}
   end

   def generate_books

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
end
