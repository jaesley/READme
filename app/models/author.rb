class Author < ApplicationRecord
  has_many :follows
  has_many :followers, through: :follows, source: :user
  has_many :books

  validates :name, :goodreads_id, presence: true
  validates :goodreads_id, uniqueness: true

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
    books_request = RestClient.get "http://www.goodreads.com/author/list/#{goodreads_id}?key=#{ENV['GOODREADS_API_KEY']}&v=2&per_page=200&page=#{page}"
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
