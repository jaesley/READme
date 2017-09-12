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

  def generate_records
    generate_authors_all_pages

    pp authors

    authors.each do |author|
      if author.works_count == nil
        # Author will generate pages
        # page_number = 1
        # author.generate_books_page(page_number)
      end
    end
  end

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

  def generate_authors_all_pages
    page_number = 1
    total_reviews = 0
    hydra = Typhoeus::Hydra.new(max_concurrency: 200)

    first_request = Typhoeus::Request.new("http://www.goodreads.com/review/list/#{uid}?key=#{ENV['GOODREADS_API_KEY']}&page=#{page_number}&per_page=1&shelf=read")
    first_request.on_complete do |response|
      response = Hash.from_xml(response.body)
      total_reviews = response['GoodreadsResponse']['books']['total'].to_i
    end

    first_request.run

    if total_reviews > reviews_count
      new_reviews = total_reviews - reviews_count.to_i
      update_attributes(reviews_count: total_reviews)

      if new_reviews < 200
        request = Typhoeus::Request.new("http://www.goodreads.com/review/list/#{uid}?key=#{ENV['GOODREADS_API_KEY']}&page=#{page_number}&per_page=#{new_reviews}&shelf=read")
        request.on_complete do |response|
          response = Hash.from_xml(response.body)
          generate_authors(response)
        end
        hydra.queue request
      else
        page_count = (new_reviews / 200) + 1
        page_count.times do |x|
          page_number = x + 1
          request = Typhoeus::Request.new("http://www.goodreads.com/review/list/#{uid}?key=#{ENV['GOODREADS_API_KEY']}&page=#{page_number}&per_page=200&shelf=read")
          request.on_complete do |response|
            response = Hash.from_xml(response.body)
            generate_authors(response)
          end
          hydra.queue request
        end
      end

      hydra.run
    end
  end
end
