require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(user_name: 'hayley', uid: '3702636', provider: 'Goodreads', password: 'pw') }

  context '#associations' do
    it { is_expected.to have_many :follows }
    it { is_expected.to have_many :authors }
    it { is_expected.to have_many :books }
  end

  describe '#generate_records' do
    before(:each) do
      page = RestClient.get "http://www.goodreads.com/review/list/#{user.uid}?key=#{ENV['GOODREADS_API_KEY']}&sort=author&per_page=5&shelf=read"
      @page = Hash.from_xml(page.to_s)
      @books = @page['GoodreadsResponse']['books']['book']
      review = @page['GoodreadsResponse']['books']['book'][0]
      @author = user.generate_author_hash(review)
    end

    context '#generate_follow' do
      let(:author) { Author.create(@author) }

      it 'is a valid instance of Follow' do
        follow = user.generate_follow(author)
        expect(follow).to be_valid
      end

      it 'saves the follow instance to the database' do
        expect{user.generate_follow(author)}.to change(Follow, :count).from(0).to(1)
      end
    end

    context '#generate_author_hash' do
      it 'returns a hash' do
        expect(@author).to be_a Hash
      end

      it 'has a name' do
        expect(@author[:name]).to_not be nil
      end

      it 'has a goodreads id' do
        expect(@author[:goodreads_id]).to_not be nil
      end

      it 'has a link to author page' do
        expect(@author[:link]).to_not be nil
      end
    end

    context '#generate_author' do
      it 'is a valid instance of Author' do
        author = user.generate_author(@author)
        expect(author).to be_valid
      end

      it 'saves the author instance to the database' do
        expect{user.generate_author(@author)}.to change(Author, :count).from(0).to(1)
      end
    end

    context '#generate_authors' do
      it 'saves multiple authors to the database' do
        authors = []
        @books.each { |book| authors << user.generate_author_hash(book) }
        authors.uniq!
        expect{user.generate_authors(@page)}.to change(Author, :count).from(0).to(authors.count)
      end
    end

    context '#generate_authors_all_pages' do

    end
  end

  context '#generate_records' do

  end
end
