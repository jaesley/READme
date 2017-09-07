require 'pp'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:goodreads]

  has_many :follows
  has_many :authors, through: :follows
  has_many :books, through: :authors

# :nocov:
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
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
  # :nocov:

  # RECORD GENERATION

  def generate_records(current_user)
    @current_user = User.last
    create_authors
    # @author_hashes = []
    # @authors = generate_authors
    # @authors.each do |author|
    #   generate_books(author)
    # end
  end

  def generate_author_hashes(body)
    author_hashes = []
    body['GoodreadsResponse']['books']['book'].each do |book|
      # author = generate_author_hash(review)
      author = {}
      author_hashes << author
    end
    author_hashes
  end

  def get_author_single_page(page_number)
    reviews = RestClient.get "http://www.goodreads.com/review/list/#{uid}?key=#{ENV['GOODREADS_API_KEY']}&sort=author&per_page=200&shelf=read"
    reviews = Hash.from_xml(reviews.to_s)
    total = reviews['GoodreadsResponse']['books']['total'].to_i
    # author_hashes = generate_author_hashes(reviews)
    author_hashes = [{}, {}]
    {author_hashes: author_hashes, total: total}
  end

  def get_author_all_pages
    page_number = 1
    page_hash = get_author_single_page(page_number)
    author_hashes = page_hash[:author_hashes]
    pages = page_hash[:total] / 200

    pages.times do |x|
      page_hash = get_author_single_page(x+2)
      author_hashes += page_hash[:author_hashes]
    end
    author_hashes
  end









  def generate_author_hash(review)
    name = review['book']['authors']['author']['name']
    link = review['book']['authors']['author']['link']
    goodreads_id = review['book']['authors']['author']['id']
    {name: name, goodreads_id: goodreads_id, link: link}
  end






  def create_authors
    author_hashes = get_author_all_pages
    pp author_hashes
  end





    def generate_authors
      page = 1
      body = generate_authors_page(page)
      total = body['GoodreadsResponse']['reviews']['total'].to_i
      while total > 200
        page += 1
        total -= 200
        generate_authors_page(page)
      end

      @author_hashes.each do |author|
        generate_author(author)
      end

      @current_user.authors
    end

    def generate_authors_page(page)
      authors_request = RestClient.get "http://www.goodreads.com/review/list/#{@current_user.uid}?key=#{ENV['GOODREADS_API_KEY']}&v=2&sort=author&per_page=200&shelf=read"
      generate_author_hashes(Hash.from_xml(authors_request))
      Hash.from_xml(authors_request)
    end

    def generate_author(author)
      Author.where(goodreads_id: author[:goodreads_id]).first_or_create.update_attributes(name: author[:name], link: author[:link])
      generate_follow(Author.find_by(goodreads_id: author[:goodreads_id]))
    end

    def generate_follow(author)
      if !@current_user.authors.include? author
        @current_user.authors << author
      end
      author
    end



    def generate_books(author)
      page = 1
      body = generate_books_page(author, page)
      total = body['GoodreadsResponse']['author']['books']['total'].to_i
      while total > 200
        page += 1
        total -= 200
        generate_books_page(author, page)
      end
    end

    def generate_books_page(author, page)
      books_request = RestClient.get "http://www.goodreads.com/author/list/#{author.goodreads_id}?key=#{ENV['GOODREADS_API_KEY']}&v=2&per_page=200&page=#{page}"
      generate_book_hashes(author.id, Hash.from_xml(books_request))
      Hash.from_xml(books_request)
    end

    def generate_book_hashes(author_id, books)
      books['GoodreadsResponse']['author']['books']['book'].each do |book|
        begin
          book = generate_book_hash(author_id, book)
          generate_book(book)
        rescue
          next
        end
      end
    end

    def generate_book_hash(author_id, book)
      pub_date = "#{book['publication_year']}-#{book['publication_month']}-#{book['publication_day']}"
      if Date.parse(pub_date) >= Date.today
        title = book['title_without_series']
        goodreads_id = book['id']
        link = book['link']

        isbn = get_isbn(book)

        {title: title, goodreads_id: goodreads_id, isbn: isbn, author_id: author_id, link: link, publication_date: pub_date}
      end
    end

    def get_isbn(book)
      book['isbn'] ? book['isbn'] : book['isbn10']
    end

    def generate_book(book)
      Book.where(goodreads_id: book[:goodreads_id]).first_or_create.update_attributes(title: book[:title], isbn: book[:isbn], publication_date: book[:publication_date], author_id: book[:author_id], link: book[:link])
    end
end
