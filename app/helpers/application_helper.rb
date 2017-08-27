module ApplicationHelper
  def generate_records(current_user)
    @current_user = current_user
    @author_hashes = []
    @authors = generate_authors
    @authors.each do |author|
      generate_books(author)
    end
  end

  private

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

  def generate_author_hashes(body)
    body['GoodreadsResponse']['reviews']['review'].each do |review|
      author = generate_author_hash(review)
      @author_hashes << author
    end
    @author_hashes
  end

  def generate_author_hash(review)
    name = review['book']['authors']['author']['name']
    link = review['book']['authors']['author']['link']
    goodreads_id = review['book']['authors']['author']['id']
    {name: name, goodreads_id: goodreads_id, link: link}
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
      p link
      p "*" * 1000
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
