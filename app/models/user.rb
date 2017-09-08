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

  def generate_follow(author)
    if !authors.include? author
      authors << author
    end
    Follow.find_by(user_id: id, author_id: author.id)
  end

  def generate_author(author)
    Author.where(goodreads_id: author[:goodreads_id]).first_or_create.update_attributes(name: author[:name], link: author[:link])
    author = Author.find_by(goodreads_id: author[:goodreads_id])
    generate_follow(author)
    author
  end

  def generate_author_hash(review)
    name = review['authors']['author']['name']
    link = review['authors']['author']['link']
    goodreads_id = review['authors']['author']['id']
    {name: name, goodreads_id: goodreads_id, link: link}
  end

  def generate_authors(page)
    page['GoodreadsResponse']['books']['book'].each do |book|
      author = generate_author_hash(book)
      generate_author(author)
    end
  end

  def generate_authors_single_page(page_number)
    page = RestClient.get "http://www.goodreads.com/review/list/#{uid}?key=#{ENV['GOODREADS_API_KEY']}&sort=author&per_page=200&shelf=read"
    page = Hash.from_xml(page.to_s)
    generate_authors(page)
    page['GoodreadsResponse']['books']['total'].to_i
  end

  def generate_authors_all_pages
    page_number = 1
    total_reviews = generate_author_single_page(page_number)
    pages = total_reviews / 200

    pages.times do |x|
      generate_author_single_page(x+2)
    end
  end













  def generate_records(current_user)
    @current_user = User.last
    create_authors
    # @author_hashes = []
    # @authors = generate_authors
    # @authors.each do |author|
    #   generate_books(author)
    # end
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
